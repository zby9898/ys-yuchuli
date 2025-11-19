function output_data = test_figure_display(input_data, params)
% TEST_FIGURE_DISPLAY 测试缓存figure显示功能（包含文字、数字、图例等所有元素）
%
% 此脚本用于测试系统对缓存figure的完整显示能力，包括：
% - 标题（Title）及其格式
% - 轴标签（XLabel/YLabel）及其格式
% - 文字标注（text对象）
% - 数字标注（text对象显示数字）
% - 图例（legend）及其位置
% - 颜色条（colorbar）及其标签
% - 网格线（grid）及其样式
% - 线条（line对象）
% - 形状标记（scatter、rectangle等）
%
% 参数定义：
% PARAM: show_grid, bool, true
% PARAM: show_legend, bool, true
% PARAM: show_colorbar, bool, true
% PARAM: add_markers, bool, true

    % 获取参数
    show_grid = getParam(params, 'show_grid', true);
    show_legend = getParam(params, 'show_legend', true);
    show_colorbar = getParam(params, 'show_colorbar', true);
    add_markers = getParam(params, 'add_markers', true);

    % 确保输入为复数矩阵
    if ~isnumeric(input_data)
        error('输入数据必须是数值类型');
    end

    % 转换为double类型
    input_data = double(input_data);

    % 计算幅度（用于显示）
    magnitude = abs(input_data);
    magnitude_db = 20 * log10(magnitude + eps);

    % 创建figure（不可见，用于缓存）
    fig = figure('Visible', 'off', 'Color', 'white');
    fig.Position = [100, 100, 800, 600];
    ax = axes(fig);

    % 显示主图像
    imagesc(ax, magnitude_db);
    colormap(ax, 'jet');
    hold(ax, 'on');

    % ========== 1. 添加标题 ==========
    title(ax, '测试图 - 完整显示功能', ...
          'FontSize', 14, ...
          'FontWeight', 'bold', ...
          'Color', [0 0 0.5], ...
          'Interpreter', 'none');

    % ========== 2. 添加轴标签 ==========
    xlabel(ax, '距离单元 (Range Bins)', 'FontSize', 12, 'Color', [0 0 0]);
    ylabel(ax, '多普勒单元 (Doppler Bins)', 'FontSize', 12, 'Color', [0 0 0]);

    % ========== 3. 添加网格线 ==========
    if show_grid
        grid(ax, 'on');
        ax.GridLineStyle = '--';
        ax.GridColor = [0.5 0.5 0.5];
        ax.GridAlpha = 0.5;
    end

    % ========== 4. 添加颜色条及其标签 ==========
    if show_colorbar
        cb = colorbar(ax);
        cb.Label.String = '幅度 (dB)';
        cb.Label.FontSize = 11;
        cb.Label.Rotation = 270;
        cb.Label.VerticalAlignment = 'bottom';
    end

    % ========== 5. 添加文字标注 ==========
    [rows, cols] = size(magnitude_db);

    % 找到最大值位置
    [max_val, max_idx] = max(magnitude_db(:));
    [max_row, max_col] = ind2sub([rows, cols], max_idx);

    % 在最大值位置添加标注
    text(ax, max_col, max_row, '  ← 最大值', ...
         'Color', 'white', ...
         'FontSize', 11, ...
         'FontWeight', 'bold', ...
         'BackgroundColor', [0 0 0 0.5], ...
         'EdgeColor', 'white');

    % 添加数字标注
    text(ax, max_col, max_row + 5, sprintf('  值: %.2f dB', max_val), ...
         'Color', 'yellow', ...
         'FontSize', 10, ...
         'FontWeight', 'normal', ...
         'BackgroundColor', [0 0 0 0.3]);

    % 在左上角添加统计信息文字
    info_text = sprintf('统计信息:\n最大值: %.2f dB\n平均值: %.2f dB\n标准差: %.2f dB', ...
                        max_val, mean(magnitude_db(:)), std(magnitude_db(:)));
    text(ax, cols * 0.02, rows * 0.15, info_text, ...
         'Color', 'white', ...
         'FontSize', 9, ...
         'FontWeight', 'normal', ...
         'BackgroundColor', [0 0 0 0.6], ...
         'EdgeColor', 'cyan', ...
         'LineWidth', 1, ...
         'VerticalAlignment', 'top');

    % ========== 6. 添加标记点和线条 ==========
    if add_markers
        % 在几个位置添加标记点
        marker_positions = [
            round(cols * 0.3), round(rows * 0.3);
            round(cols * 0.5), round(rows * 0.5);
            round(cols * 0.7), round(rows * 0.7);
        ];

        % 绘制标记点
        scatter(ax, marker_positions(:,1), marker_positions(:,2), ...
                100, 'red', 'filled', 'o', ...
                'MarkerEdgeColor', 'white', 'LineWidth', 2);

        % 添加标记点的编号
        for i = 1:size(marker_positions, 1)
            text(ax, marker_positions(i,1) + 2, marker_positions(i,2), ...
                 sprintf(' 目标%d', i), ...
                 'Color', 'white', ...
                 'FontSize', 10, ...
                 'FontWeight', 'bold');
        end

        % 绘制连接线
        plot(ax, marker_positions(:,1), marker_positions(:,2), ...
             'g--', 'LineWidth', 2);

        % 绘制矩形框（ROI示例）
        rect_x = cols * 0.6;
        rect_y = rows * 0.2;
        rect_w = cols * 0.3;
        rect_h = rows * 0.3;
        rectangle(ax, 'Position', [rect_x, rect_y, rect_w, rect_h], ...
                  'EdgeColor', 'magenta', 'LineWidth', 2, 'LineStyle', '-');
        text(ax, rect_x + rect_w/2, rect_y - 2, 'ROI区域', ...
             'Color', 'magenta', 'FontSize', 10, 'FontWeight', 'bold', ...
             'HorizontalAlignment', 'center');
    end

    % ========== 7. 添加图例 ==========
    if show_legend && add_markers
        % 创建图例项
        h1 = plot(ax, NaN, NaN, 'ro', 'MarkerFaceColor', 'red', 'MarkerSize', 10);
        h2 = plot(ax, NaN, NaN, 'g--', 'LineWidth', 2);
        h3 = plot(ax, NaN, NaN, 'm-', 'LineWidth', 2);

        leg = legend(ax, [h1, h2, h3], {'目标标记', '连接线', 'ROI边界'}, ...
                     'Location', 'southeast', ...
                     'FontSize', 9, ...
                     'TextColor', 'black', ...
                     'EdgeColor', 'black');
    end

    hold(ax, 'off');

    % 计算一些统计值
    num_peaks = sum(magnitude_db(:) > (max_val - 10));  % 接近最大值的点数

    % 创建输出结构体
    output_data = struct();
    output_data.complex_matrix = input_data;  % 保持原始复数数据
    output_data.magnitude_db = magnitude_db;  % 幅度（dB）
    output_data.max_value = max_val;
    output_data.max_position = [max_row, max_col];
    output_data.mean_value = mean(magnitude_db(:));
    output_data.std_value = std(magnitude_db(:));
    output_data.num_peaks = num_peaks;
    output_data.name = '测试显示';
    output_data.timestamp = datetime('now');

    % ⭐ 关键：将figure保存到additional_outputs的cached_figure字段
    output_data.additional_outputs = struct('cached_figure', fig);

    fprintf('\n========== 测试脚本执行完成 ==========\n');
    fprintf('✅ 已生成包含以下元素的测试图：\n');
    fprintf('   - 标题（粗体、深蓝色）\n');
    fprintf('   - 轴标签（距离单元、多普勒单元）\n');
    fprintf('   - 文字标注（最大值位置、统计信息）\n');
    fprintf('   - 数字标注（最大值、平均值、标准差）\n');
    if show_colorbar
        fprintf('   - 颜色条及标签（幅度 dB）\n');
    end
    if show_grid
        fprintf('   - 网格线（虚线、灰色、半透明）\n');
    end
    if add_markers
        fprintf('   - 标记点（3个红色圆圈）\n');
        fprintf('   - 连接线（绿色虚线）\n');
        fprintf('   - 矩形框（品红色ROI区域）\n');
    end
    if show_legend && add_markers
        fprintf('   - 图例（右下角）\n');
    end
    fprintf('=======================================\n\n');
    fprintf('统计信息：\n');
    fprintf('  最大值: %.2f dB，位置: (%d, %d)\n', max_val, max_row, max_col);
    fprintf('  平均值: %.2f dB\n', output_data.mean_value);
    fprintf('  标准差: %.2f dB\n', output_data.std_value);
    fprintf('  峰值点数: %d\n', num_peaks);
    fprintf('=======================================\n');

end

function value = getParam(params, name, default_value)
    % 辅助函数：从params结构体中获取参数值
    if isfield(params, name)
        value = params.(name);
    else
        value = default_value;
    end
end
