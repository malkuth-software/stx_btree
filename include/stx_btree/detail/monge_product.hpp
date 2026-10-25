#pragma once

// Min-plus products of Monge matrices kept in condensed form, after
// Gawrychowski, Gorbachev and Kociumaka (core-sparse Monge products, ESA
// 2025), as the optimal search tree construction uses them (optimal_tree.hpp;
// manuscript section "Core-sparse Monge construction"). This is a house-style
// rewrite of papers_please obst/code/compact_obst.cpp: the same algorithm, the
// same witness structure (ordinary arrays, not the paper's succinct storage),
// with compressed-row storage in place of per-row lists.
//
// A matrix M with rows x columns entries is Monge when every density
//     d(i, j) = M(i, j + 1) + M(i + 1, j) - M(i, j) - M(i + 1, j + 1)
// is non-negative. It is kept as its top row, its left column and the
// nonzero densities (its core); then
//     M(i, j) = M(i, 0) + M(0, j) - M(0, 0) - sum over a < i, b < j of d(a, b).
// Products touch the core and the two borders, never the whole matrix.
//
// All values are exact integers (ExactCost). The caller bounds them; nothing
// here checks overflow.

#include "stx_btree/search_weights.hpp"

#include <cassert>
#include <cstdint>
#include <memory>
#include <vector>

namespace stx_btree::detail {

using MatrixIndex = std::int32_t;

// A nonzero density d(row, column), 0 <= row < rows - 1, 0 <= column < columns - 1.
struct Density final {
    MatrixIndex row = 0;
    MatrixIndex column = 0;
    ExactCost value = 0;
};

// One density of a column list (index = its row).
struct ColumnDensity final {
    MatrixIndex row = 0;
    ExactCost value = 0;
};

class CondensedMatrix final {
public:
    std::vector<ExactCost> top;  // M(0, j), one per column
    std::vector<ExactCost> left; // M(i, 0), one per row; left[0] == top[0]
    // The core, row-major with columns ascending, one record per cell. The
    // densities of row i are core[row_begin[i], row_begin[i + 1]), so the
    // densities above row i are the prefix core[0, row_begin[i]). row_begin
    // has one entry per matrix row; its last entry is core.size().
    std::vector<Density> core;
    std::vector<MatrixIndex> row_begin;
    // The same densities column-major with rows ascending, delimited the same
    // way by column_begin (one entry per matrix column).
    std::vector<ColumnDensity> by_column;
    std::vector<MatrixIndex> column_begin;

    [[nodiscard]] MatrixIndex rows() const noexcept {
        return static_cast<MatrixIndex>(left.size());
    }
    [[nodiscard]] MatrixIndex columns() const noexcept {
        return static_cast<MatrixIndex>(top.size());
    }
    [[nodiscard]] MatrixIndex core_size() const noexcept {
        return static_cast<MatrixIndex>(core.size());
    }
    [[nodiscard]] bool row_has_density(MatrixIndex row) const noexcept {
        const std::size_t index = static_cast<std::size_t>(row);
        return row_begin[index] != row_begin[index + 1];
    }
    [[nodiscard]] bool column_has_density(MatrixIndex column) const noexcept {
        const std::size_t index = static_cast<std::size_t>(column);
        return column_begin[index] != column_begin[index + 1];
    }

    // Builds the matrix from its borders and densities in any order; repeated
    // cells are summed. Every density must be positive and inside the core.
    [[nodiscard]] static CondensedMatrix from_densities(
        std::vector<ExactCost> top_row, std::vector<ExactCost> left_column,
        const std::vector<Density>& densities) {
        CondensedMatrix matrix;
        matrix.top = std::move(top_row);
        matrix.left = std::move(left_column);
        const std::size_t row_count = matrix.left.size();
        const std::size_t column_count = matrix.top.size();
        assert(row_count > 0 && column_count > 0 && matrix.top[0] == matrix.left[0]);
        const std::size_t density_count = densities.size();

        // Two stable counting sorts, by column and then by row, leave the
        // densities row-major with columns ascending inside each row.
        std::vector<MatrixIndex> column_start(column_count, 0);
        std::size_t index = 0;
        for (index = 0; index < density_count; index += 1) {
            const Density& density = densities[index];
            assert(density.value > 0);
            assert(density.row >= 0 && static_cast<std::size_t>(density.row) + 1 < row_count);
            assert(density.column >= 0 && static_cast<std::size_t>(density.column) + 1 < column_count);
            column_start[static_cast<std::size_t>(density.column) + 1] += 1;
        }
        prefix_sums(column_start);
        std::vector<Density> column_order(density_count);
        std::vector<MatrixIndex> next = column_start;
        for (index = 0; index < density_count; index += 1) {
            const Density& density = densities[index];
            const std::size_t column = static_cast<std::size_t>(density.column);
            column_order[static_cast<std::size_t>(next[column])] = density;
            next[column] += 1;
        }
        std::vector<MatrixIndex> row_start(row_count, 0);
        for (index = 0; index < density_count; index += 1) {
            row_start[static_cast<std::size_t>(column_order[index].row) + 1] += 1;
        }
        prefix_sums(row_start);
        std::vector<Density> row_order(density_count);
        next = row_start;
        for (index = 0; index < density_count; index += 1) {
            const Density& density = column_order[index];
            const std::size_t row = static_cast<std::size_t>(density.row);
            row_order[static_cast<std::size_t>(next[row])] = density;
            next[row] += 1;
        }

        // Repeats of one cell are now adjacent: sum them.
        matrix.core.reserve(density_count);
        for (index = 0; index < density_count; index += 1) {
            const Density& density = row_order[index];
            if (!matrix.core.empty() && matrix.core.back().row == density.row &&
                matrix.core.back().column == density.column) {
                matrix.core.back().value += density.value;
            } else {
                matrix.core.push_back(density);
            }
        }

        const std::size_t core_count = matrix.core.size();
        matrix.row_begin.assign(row_count, 0);
        matrix.column_begin.assign(column_count, 0);
        for (index = 0; index < core_count; index += 1) {
            const Density& density = matrix.core[index];
            matrix.row_begin[static_cast<std::size_t>(density.row) + 1] += 1;
            matrix.column_begin[static_cast<std::size_t>(density.column) + 1] += 1;
        }
        prefix_sums(matrix.row_begin);
        prefix_sums(matrix.column_begin);
        matrix.by_column.resize(core_count);
        next = matrix.column_begin;
        for (index = 0; index < core_count; index += 1) {
            const Density& density = matrix.core[index];
            const std::size_t column = static_cast<std::size_t>(density.column);
            matrix.by_column[static_cast<std::size_t>(next[column])] =
                ColumnDensity{.row = density.row, .value = density.value};
            next[column] += 1;
        }
        return matrix;
    }

    // Row `row` in full.
    [[nodiscard]] std::vector<ExactCost> row_values(MatrixIndex row) const {
        const std::size_t column_count = top.size();
        std::vector<ExactCost> mass_above(column_count, 0);
        const std::size_t above_end = static_cast<std::size_t>(row_begin[static_cast<std::size_t>(row)]);
        std::size_t index = 0;
        for (index = 0; index < above_end; index += 1) {
            mass_above[static_cast<std::size_t>(core[index].column)] += core[index].value;
        }
        std::vector<ExactCost> values(column_count, 0);
        const ExactCost row_start = left[static_cast<std::size_t>(row)];
        ExactCost passed = 0;
        for (index = 0; index < column_count; index += 1) {
            values[index] = row_start + top[index] - top[0] - passed;
            passed += mass_above[index];
        }
        return values;
    }

    // Column `column` in full.
    [[nodiscard]] std::vector<ExactCost> column_values(MatrixIndex column) const {
        const std::size_t row_count = left.size();
        std::vector<ExactCost> mass_before(row_count, 0);
        const std::size_t before_end = static_cast<std::size_t>(column_begin[static_cast<std::size_t>(column)]);
        std::size_t index = 0;
        for (index = 0; index < before_end; index += 1) {
            mass_before[static_cast<std::size_t>(by_column[index].row)] += by_column[index].value;
        }
        std::vector<ExactCost> values(row_count, 0);
        const ExactCost column_start = top[static_cast<std::size_t>(column)];
        ExactCost passed = 0;
        for (index = 0; index < row_count; index += 1) {
            values[index] = column_start + left[index] - left[0] - passed;
            passed += mass_before[index];
        }
        return values;
    }

    // M(row, column + 1) from value = M(row, column); column + 1 < columns.
    [[nodiscard]] ExactCost value_right(MatrixIndex row, MatrixIndex column, ExactCost value) const noexcept {
        const std::size_t first = static_cast<std::size_t>(column_begin[static_cast<std::size_t>(column)]);
        const std::size_t end = static_cast<std::size_t>(column_begin[static_cast<std::size_t>(column) + 1]);
        ExactCost mass_above = 0;
        std::size_t index = 0;
        for (index = first; index < end; index += 1) {
            if (by_column[index].row >= row) {
                break;
            }
            mass_above += by_column[index].value;
        }
        const std::size_t here = static_cast<std::size_t>(column);
        return value + top[here + 1] - top[here] - mass_above;
    }

    // M(row, column) from value = M(row + 1, column); row + 1 < rows.
    [[nodiscard]] ExactCost value_up(MatrixIndex row, MatrixIndex column, ExactCost value) const noexcept {
        const std::size_t first = static_cast<std::size_t>(row_begin[static_cast<std::size_t>(row)]);
        const std::size_t end = static_cast<std::size_t>(row_begin[static_cast<std::size_t>(row) + 1]);
        ExactCost mass_before = 0;
        std::size_t index = 0;
        for (index = first; index < end; index += 1) {
            if (core[index].column >= column) {
                break;
            }
            mass_before += core[index].value;
        }
        const std::size_t here = static_cast<std::size_t>(row);
        return value - left[here + 1] + left[here] + mass_before;
    }

    // The submatrix of rows row_cuts[0] < row_cuts[1] < ... and columns
    // column_cuts[...]. A density of this matrix lands in the submatrix cell
    // whose row interval [row_cuts[k], row_cuts[k + 1]) and column interval
    // contain it; densities outside every interval drop out.
    [[nodiscard]] CondensedMatrix select(
        const std::vector<MatrixIndex>& row_cuts, const std::vector<MatrixIndex>& column_cuts) const {
        const std::vector<MatrixIndex> row_part = cut_parts(rows(), row_cuts);
        const std::vector<MatrixIndex> column_part = cut_parts(columns(), column_cuts);
        const std::vector<ExactCost> first_row = row_values(row_cuts[0]);
        const std::vector<ExactCost> first_column = column_values(column_cuts[0]);
        std::vector<ExactCost> top_row(column_cuts.size(), 0);
        std::vector<ExactCost> left_column(row_cuts.size(), 0);
        std::size_t index = 0;
        for (index = 0; index < column_cuts.size(); index += 1) {
            top_row[index] = first_row[static_cast<std::size_t>(column_cuts[index])];
        }
        for (index = 0; index < row_cuts.size(); index += 1) {
            left_column[index] = first_column[static_cast<std::size_t>(row_cuts[index])];
        }
        std::vector<Density> densities;
        for (index = 0; index < core.size(); index += 1) {
            const Density& density = core[index];
            const MatrixIndex row = row_part[static_cast<std::size_t>(density.row)];
            const MatrixIndex column = column_part[static_cast<std::size_t>(density.column)];
            if (row >= 0 && column >= 0) {
                densities.push_back(Density{.row = row, .column = column, .value = density.value});
            }
        }
        return from_densities(std::move(top_row), std::move(left_column), densities);
    }

    // Index k of the interval [cuts[k], cuts[k + 1]) holding each position
    // below extent, or -1 outside them all.
    [[nodiscard]] static std::vector<MatrixIndex> cut_parts(MatrixIndex extent, const std::vector<MatrixIndex>& cuts) {
        std::vector<MatrixIndex> parts(static_cast<std::size_t>(extent), -1);
        std::size_t part = 0;
        for (part = 0; part + 1 < cuts.size(); part += 1) {
            MatrixIndex position = 0;
            for (position = cuts[part]; position < cuts[part + 1]; position += 1) {
                parts[static_cast<std::size_t>(position)] = static_cast<MatrixIndex>(part);
            }
        }
        return parts;
    }

    // Index k of the group [cuts[k], cuts[k + 1]) holding each position below
    // extent, the last group running to extent; cuts[0] must be 0.
    [[nodiscard]] static std::vector<MatrixIndex> cut_groups(MatrixIndex extent, const std::vector<MatrixIndex>& cuts) {
        assert(!cuts.empty() && cuts[0] == 0);
        std::vector<MatrixIndex> groups(static_cast<std::size_t>(extent), 0);
        std::size_t group = 0;
        for (group = 0; group < cuts.size(); group += 1) {
            const MatrixIndex end = group + 1 < cuts.size() ? cuts[group + 1] : extent;
            MatrixIndex position = 0;
            for (position = cuts[group]; position < end; position += 1) {
                groups[static_cast<std::size_t>(position)] = static_cast<MatrixIndex>(group);
            }
        }
        return groups;
    }

    [[nodiscard]] static std::vector<MatrixIndex> index_range(MatrixIndex first, MatrixIndex end) {
        std::vector<MatrixIndex> indices;
        indices.reserve(static_cast<std::size_t>(end - first));
        MatrixIndex index = 0;
        for (index = first; index < end; index += 1) {
            indices.push_back(index);
        }
        return indices;
    }

private:
    // Counts at [k + 1] become starts at [k]: exclusive prefix sums in place.
    static void prefix_sums(std::vector<MatrixIndex>& counts) noexcept {
        std::size_t index = 0;
        for (index = 1; index < counts.size(); index += 1) {
            counts[index] += counts[index - 1];
        }
    }
};

// Which inner index realizes each entry of a product, for reconstruction.
// A node maps original rows and columns to its compressed ones and its
// compressed inner indices back to original ones; a leaf stores the choice
// per compressed cell, a split node defers to the half that won the cell.
class ProductWitness final {
public:
    std::vector<MatrixIndex> row_group;
    std::vector<MatrixIndex> column_group;
    std::vector<MatrixIndex> inner;
    std::vector<MatrixIndex> border;      // split: last compressed column won by the left half, per compressed row
    std::vector<MatrixIndex> leaf_choice; // leaf: compressed rows x leaf_columns
    MatrixIndex leaf_columns = 0;
    MatrixIndex cut = 0;                  // split: first compressed inner index of the right half
    std::unique_ptr<ProductWitness> left_half;
    std::unique_ptr<ProductWitness> right_half;

    // An inner index k with A(row, k) + B(k, column) minimal.
    [[nodiscard]] MatrixIndex query(MatrixIndex row, MatrixIndex column) const noexcept {
        const MatrixIndex compressed_row = row_group[static_cast<std::size_t>(row)];
        const MatrixIndex compressed_column = column_group[static_cast<std::size_t>(column)];
        MatrixIndex choice = 0;
        if (!leaf_choice.empty()) {
            const std::size_t cell = static_cast<std::size_t>(compressed_row) * static_cast<std::size_t>(leaf_columns) +
                                     static_cast<std::size_t>(compressed_column);
            choice = leaf_choice[cell];
        } else if (compressed_column <= border[static_cast<std::size_t>(compressed_row)]) {
            choice = (*left_half).query(compressed_row, compressed_column);
        } else {
            choice = cut + (*right_half).query(compressed_row, compressed_column);
        }
        return inner[static_cast<std::size_t>(choice)];
    }

    [[nodiscard]] std::size_t slot_count() const noexcept {
        std::size_t slots = row_group.size() + column_group.size() + inner.size() + border.size() + leaf_choice.size();
        if (left_half) {
            slots += (*left_half).slot_count();
        }
        if (right_half) {
            slots += (*right_half).slot_count();
        }
        return slots;
    }
};

struct MongeProduct final {
    CondensedMatrix matrix;
    std::unique_ptr<ProductWitness> witness;
};

class MongeMultiplier final {
public:
    // Products whose compressed result has at most this many cells are
    // computed densely: constant size, linear in the compressed inner extent.
    static constexpr std::int64_t dense_leaf_cells = 64;

    // C = A (min,+) B, C(i, j) = min over k of A(i, k) + B(k, j). With
    // screen_roots, inner indices that cannot be the smallest minimizer of
    // any entry are dropped first (screen_roots below); the witnesses still
    // give the smallest minimizer, so the product is the same either way.
    [[nodiscard]] static MongeProduct multiply(const CondensedMatrix& a, const CondensedMatrix& b, bool screen_roots) {
        assert(a.columns() == b.rows());
        const MatrixIndex inner_extent = a.columns();

        // Rows of A between which A has no density differ by a constant, so
        // they share their minimizers: keep the first of each run. Likewise
        // for the columns of B and, on the inner axis, keep the index whose
        // A(0, k) + B(k, 0) is least among indices with no density between.
        std::vector<MatrixIndex> row_cuts{0};
        std::vector<MatrixIndex> column_cuts{0};
        std::vector<MatrixIndex> inner_bounds{0};
        MatrixIndex index = 0;
        for (index = 0; index + 1 < a.rows(); index += 1) {
            if (a.row_has_density(index)) {
                row_cuts.push_back(index + 1);
            }
        }
        for (index = 0; index + 1 < b.columns(); index += 1) {
            if (b.column_has_density(index)) {
                column_cuts.push_back(index + 1);
            }
        }
        for (index = 0; index + 1 < inner_extent; index += 1) {
            if (a.column_has_density(index) || b.row_has_density(index)) {
                inner_bounds.push_back(index + 1);
            }
        }
        inner_bounds.push_back(inner_extent);
        std::vector<MatrixIndex> inner_kept;
        std::size_t run = 0;
        for (run = 0; run + 1 < inner_bounds.size(); run += 1) {
            MatrixIndex best_index = inner_bounds[run];
            ExactCost best = a.top[static_cast<std::size_t>(best_index)] + b.left[static_cast<std::size_t>(best_index)];
            MatrixIndex candidate = 0;
            for (candidate = inner_bounds[run] + 1; candidate < inner_bounds[run + 1]; candidate += 1) {
                const std::size_t at = static_cast<std::size_t>(candidate);
                const ExactCost value = a.top[at] + b.left[at];
                if (value < best) {
                    best = value;
                    best_index = candidate;
                }
            }
            inner_kept.push_back(best_index);
        }
        if (screen_roots && inner_kept.size() > 2) {
            inner_kept = screen_inner(a, b, inner_kept);
        }
        const CondensedMatrix compressed_a = a.select(row_cuts, inner_kept);
        const CondensedMatrix compressed_b = b.select(inner_kept, column_cuts);
        assert(compressed_a.core_size() <= a.core_size() && compressed_b.core_size() <= b.core_size());

        std::unique_ptr<ProductWitness> witness = std::make_unique<ProductWitness>();
        (*witness).row_group = CondensedMatrix::cut_groups(a.rows(), row_cuts);
        (*witness).column_group = CondensedMatrix::cut_groups(b.columns(), column_cuts);
        (*witness).inner = inner_kept;

        const std::int64_t compressed_cells =
            static_cast<std::int64_t>(compressed_a.rows()) * static_cast<std::int64_t>(compressed_b.columns());
        CondensedMatrix compressed_c;
        if (compressed_cells <= dense_leaf_cells) {
            compressed_c = multiply_dense(compressed_a, compressed_b, *witness);
        } else {
            compressed_c = multiply_split(compressed_a, compressed_b, *witness, screen_roots);
        }

        // Expand the compressed product back: a kept row or column stands for
        // its run, which differs from it by A's (or B's) border offsets.
        const std::size_t result_rows = static_cast<std::size_t>(a.rows());
        const std::size_t result_columns = static_cast<std::size_t>(b.columns());
        std::vector<ExactCost> top_row(result_columns, 0);
        std::vector<ExactCost> left_column(result_rows, 0);
        std::size_t position = 0;
        for (position = 0; position < result_columns; position += 1) {
            const std::size_t group = static_cast<std::size_t>((*witness).column_group[position]);
            const std::size_t kept = static_cast<std::size_t>(column_cuts[group]);
            top_row[position] = compressed_c.top[group] + b.top[position] - b.top[kept];
        }
        for (position = 0; position < result_rows; position += 1) {
            const std::size_t group = static_cast<std::size_t>((*witness).row_group[position]);
            const std::size_t kept = static_cast<std::size_t>(row_cuts[group]);
            left_column[position] = compressed_c.left[group] + a.left[position] - a.left[kept];
        }
        std::vector<Density> densities;
        densities.reserve(compressed_c.core.size());
        for (position = 0; position < compressed_c.core.size(); position += 1) {
            const Density& density = compressed_c.core[position];
            const MatrixIndex row = row_cuts[static_cast<std::size_t>(density.row) + 1] - 1;
            const MatrixIndex column = column_cuts[static_cast<std::size_t>(density.column) + 1] - 1;
            densities.push_back(Density{.row = row, .column = column, .value = density.value});
        }
        MongeProduct product;
        product.matrix = CondensedMatrix::from_densities(std::move(top_row), std::move(left_column), densities);
        product.witness = std::move(witness);
        assert(product.matrix.core_size() <= 2 * (a.core_size() + b.core_size()));
        return product;
    }

private:
    // Two-corner root screening (Codex Sydney, 2026-10-25; checked against
    // the cubic recurrence and Knuth in tests/optimal_tree_test.cpp). With
    // f_k(i, j) = A(i, k) + B(k, j), Monge makes f_k - f_l nondecreasing in i
    // and j for k < l. So if a later root l has f_l(0, 0) < f_k(0, 0), root k
    // loses everywhere; and if an earlier root l has
    // f_l(p - 1, r - 1) <= f_k(p - 1, r - 1), l is no worse than k everywhere
    // and wins ties. The roots kept are those in neither case: weak suffix
    // minima of the top-left corner and strict prefix minima of the
    // bottom-right. The smallest minimizer of every entry survives.
    [[nodiscard]] static std::vector<MatrixIndex> screen_inner(
        const CondensedMatrix& a, const CondensedMatrix& b, const std::vector<MatrixIndex>& roots) {
        const std::vector<ExactCost> a_last_row = a.row_values(a.rows() - 1);
        const std::vector<ExactCost> b_last_column = b.column_values(b.columns() - 1);
        const std::size_t count = roots.size();
        std::vector<bool> keep(count, true);
        // Right to left: drop k when a later root is strictly cheaper at (0, 0).
        ExactCost later_best = 0;
        std::size_t index = count;
        while (index > 0) {
            index -= 1;
            const std::size_t root = static_cast<std::size_t>(roots[index]);
            const ExactCost top_left = a.top[root] + b.left[root];
            if (index + 1 < count && top_left > later_best) {
                keep[index] = false;
            }
            if (index + 1 == count || top_left < later_best) {
                later_best = top_left;
            }
        }
        // Left to right: drop k when an earlier root is no dearer at (p-1, r-1).
        ExactCost earlier_best = 0;
        for (index = 0; index < count; index += 1) {
            const std::size_t root = static_cast<std::size_t>(roots[index]);
            const ExactCost bottom_right = a_last_row[root] + b_last_column[root];
            if (index > 0 && bottom_right >= earlier_best) {
                keep[index] = false;
            }
            if (index == 0 || bottom_right < earlier_best) {
                earlier_best = bottom_right;
            }
        }
        std::vector<MatrixIndex> kept;
        for (index = 0; index < count; index += 1) {
            if (keep[index]) {
                kept.push_back(roots[index]);
            }
        }
        assert(!kept.empty());
        return kept;
    }

    [[nodiscard]] static CondensedMatrix multiply_dense(
        const CondensedMatrix& a, const CondensedMatrix& b, ProductWitness& witness) {
        const std::size_t row_count = static_cast<std::size_t>(a.rows());
        const std::size_t column_count = static_cast<std::size_t>(b.columns());
        const std::size_t inner_count = static_cast<std::size_t>(a.columns());
        std::vector<std::vector<ExactCost>> a_rows(row_count);
        std::vector<std::vector<ExactCost>> b_columns(column_count);
        std::size_t row = 0;
        std::size_t column = 0;
        for (row = 0; row < row_count; row += 1) {
            a_rows[row] = a.row_values(static_cast<MatrixIndex>(row));
        }
        for (column = 0; column < column_count; column += 1) {
            b_columns[column] = b.column_values(static_cast<MatrixIndex>(column));
        }
        std::vector<ExactCost> values(row_count * column_count, 0);
        witness.leaf_choice.assign(row_count * column_count, 0);
        witness.leaf_columns = static_cast<MatrixIndex>(column_count);
        for (row = 0; row < row_count; row += 1) {
            for (column = 0; column < column_count; column += 1) {
                ExactCost best = a_rows[row][0] + b_columns[column][0];
                MatrixIndex best_inner = 0;
                std::size_t inner = 0;
                for (inner = 1; inner < inner_count; inner += 1) {
                    const ExactCost value = a_rows[row][inner] + b_columns[column][inner];
                    if (value < best) {
                        best = value;
                        best_inner = static_cast<MatrixIndex>(inner);
                    }
                }
                values[row * column_count + column] = best;
                witness.leaf_choice[row * column_count + column] = best_inner;
            }
        }
        std::vector<ExactCost> top_row(column_count, 0);
        std::vector<ExactCost> left_column(row_count, 0);
        for (column = 0; column < column_count; column += 1) {
            top_row[column] = values[column];
        }
        for (row = 0; row < row_count; row += 1) {
            left_column[row] = values[row * column_count];
        }
        std::vector<Density> densities;
        for (row = 0; row + 1 < row_count; row += 1) {
            for (column = 0; column + 1 < column_count; column += 1) {
                const ExactCost density = values[row * column_count + column + 1] +
                                          values[(row + 1) * column_count + column] -
                                          values[row * column_count + column] -
                                          values[(row + 1) * column_count + column + 1];
                assert(density >= 0);
                if (density != 0) {
                    densities.push_back(Density{.row = static_cast<MatrixIndex>(row),
                                                .column = static_cast<MatrixIndex>(column),
                                                .value = density});
                }
            }
        }
        return CondensedMatrix::from_densities(std::move(top_row), std::move(left_column), densities);
    }

    // Splits the inner axis where it halves the combined core, multiplies
    // the halves and keeps the cellwise minimum.
    [[nodiscard]] static CondensedMatrix multiply_split(
        const CondensedMatrix& a, const CondensedMatrix& b, ProductWitness& witness, bool screen_roots) {
        const MatrixIndex inner_extent = a.columns();
        std::vector<MatrixIndex> inner_weight(static_cast<std::size_t>(inner_extent) - 1, 0);
        std::size_t index = 0;
        for (index = 0; index < a.core.size(); index += 1) {
            inner_weight[static_cast<std::size_t>(a.core[index].column)] += 1;
        }
        for (index = 0; index < b.core.size(); index += 1) {
            inner_weight[static_cast<std::size_t>(b.core[index].row)] += 1;
        }
        const MatrixIndex total = a.core_size() + b.core_size();
        MatrixIndex passed = 0;
        MatrixIndex cut = 1;
        MatrixIndex candidate = 0;
        for (candidate = 1; candidate < inner_extent; candidate += 1) {
            if (passed > total / 2) {
                break;
            }
            cut = candidate;
            passed += inner_weight[static_cast<std::size_t>(candidate) - 1];
        }
        const std::vector<MatrixIndex> all_rows = CondensedMatrix::index_range(0, a.rows());
        const std::vector<MatrixIndex> all_columns = CondensedMatrix::index_range(0, b.columns());
        const std::vector<MatrixIndex> inner_left = CondensedMatrix::index_range(0, cut);
        const std::vector<MatrixIndex> inner_right = CondensedMatrix::index_range(cut, inner_extent);
        const CondensedMatrix a_left = a.select(all_rows, inner_left);
        const CondensedMatrix b_left = b.select(inner_left, all_columns);
        const CondensedMatrix a_right = a.select(all_rows, inner_right);
        const CondensedMatrix b_right = b.select(inner_right, all_columns);
        assert(a_left.core_size() + b_left.core_size() <= total / 2);
        assert(a_right.core_size() + b_right.core_size() <= total / 2);
        MongeProduct left_product = multiply(a_left, b_left, screen_roots);
        MongeProduct right_product = multiply(a_right, b_right, screen_roots);
        std::vector<MatrixIndex> border;
        CondensedMatrix minimum = merge_minimum(left_product.matrix, right_product.matrix, border);
        witness.border = std::move(border);
        witness.cut = cut;
        witness.left_half = std::move(left_product.witness);
        witness.right_half = std::move(right_product.witness);
        return minimum;
    }

    // Values of the 2 x 2 cells (row + r, column + c) around a staircase
    // walk, with which of them exist.
    struct StaircaseCells final {
        ExactCost value[2][2] = {{0, 0}, {0, 0}};
        bool known[2][2] = {{false, false}, {false, false}};
    };

    [[nodiscard]] static StaircaseCells step_right(
        const CondensedMatrix& matrix, const StaircaseCells& cells, MatrixIndex row, MatrixIndex column) noexcept {
        StaircaseCells moved;
        int r = 0;
        for (r = 0; r < 2; r += 1) {
            if (cells.known[r][1]) {
                moved.value[r][0] = cells.value[r][1];
                moved.known[r][0] = true;
                if (column + 2 < matrix.columns()) {
                    moved.value[r][1] = matrix.value_right(row + r, column + 1, cells.value[r][1]);
                    moved.known[r][1] = true;
                }
            }
        }
        return moved;
    }

    [[nodiscard]] static StaircaseCells step_up(
        const CondensedMatrix& matrix, const StaircaseCells& cells, MatrixIndex row, MatrixIndex column) noexcept {
        StaircaseCells moved;
        int c = 0;
        for (c = 0; c < 2; c += 1) {
            if (cells.known[0][c]) {
                moved.value[1][c] = cells.value[0][c];
                moved.known[1][c] = true;
                if (row > 0) {
                    moved.value[0][c] = matrix.value_up(row - 1, column + c, cells.value[0][c]);
                    moved.known[0][c] = true;
                }
            }
        }
        return moved;
    }

    [[nodiscard]] static ExactCost lesser(ExactCost a, ExactCost b) noexcept {
        return a < b ? a : b;
    }

    // The cellwise minimum of two Monge matrices of one shape whose left
    // operand wins a staircase (as halves of the inner axis do). border[i]
    // is the last column of row i that a wins (-1 for none); the walk from
    // the bottom-left corner traces it and emits the densities along it.
    [[nodiscard]] static CondensedMatrix merge_minimum(
        const CondensedMatrix& a, const CondensedMatrix& b, std::vector<MatrixIndex>& border) {
        assert(a.rows() == b.rows() && a.columns() == b.columns());
        const MatrixIndex row_count = a.rows();
        const MatrixIndex column_count = a.columns();
        MatrixIndex row = row_count - 1;
        MatrixIndex column = -1;
        StaircaseCells cells_a;
        StaircaseCells cells_b;
        cells_a.value[0][1] = a.left[static_cast<std::size_t>(row)];
        cells_b.value[0][1] = b.left[static_cast<std::size_t>(row)];
        cells_a.known[0][1] = true;
        cells_b.known[0][1] = true;
        border.assign(static_cast<std::size_t>(row_count), -1);
        std::vector<Density> densities;
        while (row >= 0) {
            if (row < row_count - 1 && column >= 0 && column < column_count - 1) {
                const ExactCost density = lesser(cells_a.value[0][1], cells_b.value[0][1]) +
                                          lesser(cells_a.value[1][0], cells_b.value[1][0]) -
                                          lesser(cells_a.value[0][0], cells_b.value[0][0]) -
                                          lesser(cells_a.value[1][1], cells_b.value[1][1]);
                assert(density >= 0);
                if (density != 0) {
                    densities.push_back(Density{.row = row, .column = column, .value = density});
                }
            }
            if (column + 1 < column_count && cells_a.value[0][1] <= cells_b.value[0][1]) {
                cells_a = step_right(a, cells_a, row, column);
                cells_b = step_right(b, cells_b, row, column);
                column += 1;
            } else {
                border[static_cast<std::size_t>(row)] = column;
                cells_a = step_up(a, cells_a, row, column);
                cells_b = step_up(b, cells_b, row, column);
                row -= 1;
            }
        }
        std::size_t index = 0;
        for (index = 0; index < a.core.size(); index += 1) {
            const Density& density = a.core[index];
            if (density.column < border[static_cast<std::size_t>(density.row) + 1]) {
                densities.push_back(density);
            }
        }
        for (index = 0; index < b.core.size(); index += 1) {
            const Density& density = b.core[index];
            if (density.column > border[static_cast<std::size_t>(density.row)]) {
                densities.push_back(density);
            }
        }
        std::vector<ExactCost> top_row(static_cast<std::size_t>(column_count), 0);
        std::vector<ExactCost> left_column(static_cast<std::size_t>(row_count), 0);
        for (index = 0; index < top_row.size(); index += 1) {
            top_row[index] = lesser(a.top[index], b.top[index]);
        }
        for (index = 0; index < left_column.size(); index += 1) {
            left_column[index] = lesser(a.left[index], b.left[index]);
        }
        return CondensedMatrix::from_densities(std::move(top_row), std::move(left_column), densities);
    }
};

} // namespace stx_btree::detail
