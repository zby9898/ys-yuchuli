function output_data = test_simple_text(input_data, params)
% TEST_SIMPLE_TEXT 简单测试文字和数字显示
%
% 这是一个简化版的测试脚本，专注于测试文字和数字的基本显示
%
% 参数定义：
% PARAM: title_text, string, 测试标题
% PARAM: show_numbers, bool, true

    % 获取参数
    title_text = getParam(params, 'title_text', '测试标题');
    show_numbers = getParam(params, 'show_numbers', true);

    % 确保输入为数值类型
    if ~isnumeric(input_data)
        error('输入数据必须是数值类型');
    end

    % 转换为double类型
    input_data = double(input_data);

    % 计算幅度
    magnitude = abs(input_data);
    magnitude_db = 20 * log10(magnitude + eps);

    % 创建figure
    fig = figure('Visible', 'off', 'Color', 'white');
    ax = axes(fig);

    % 显示图像
    imagesc(ax, magnitude_db);
    colormap(ax, 'jet');

    % 添加标题
    title(ax, title_text, 'FontSize', 14, 'FontWeight', 'bold', 'Color', 'blue');

    % 添加轴标签
    xlabel(ax, 'X轴 (列)', 'FontSize', 12);
    ylabel(ax, 'Y轴 (行)', 'FontSize', 12);

    % 添加颜色条
    cb = colorbar(ax);
    cb.Label.String = '幅度 (dB)';
    cb.Label.FontSize = 11;

    % 添加网格
    grid(ax, 'on');

    % 添加文字和数字标注
    [rows, cols] = size(magnitude_db);
    max_val = max(magnitude_db(:));
    min_val = min(magnitude_db(:));
    mean_val = mean(magnitude_db(:));

    hold(ax, 'on');

    % 在左上角添加文字说明
    text(ax, 5, 10, '这是文字标注', ...
         'Color', 'white', 'FontSize', 12, 'FontWeight', 'bold', ...
         'BackgroundColor', [0 0 0 0.5]);

    % 在右上角添加数字
    if show_numbers
        text(ax, cols - 50, 10, sprintf('最大值: %.2f', max_val), ...
             'Color', 'yellow', 'FontSize', 11, ...
             'BackgroundColor', [0 0 0 0.5]);

        text(ax, cols - 50, 20, sprintf('最小值: %.2f', min_val), ...
             'Color', 'cyan', 'FontSize', 11, ...
             'BackgroundColor', [0 0 0 0.5]);

        text(ax, cols - 50, 30, sprintf('平均值: %.2f', mean_val), ...
             'Color', 'white', 'FontSize', 11, ...
             'BackgroundColor', [0 0 0 0.5]);
    end

    % 在中心添加大号文字
    text(ax, cols/2, rows/2, '中心文字', ...
         'Color', 'red', 'FontSize', 16, 'FontWeight', 'bold', ...
         'HorizontalAlignment', 'center', ...
         'BackgroundColor', [1 1 1 0.7], ...
         'EdgeColor', 'red', 'LineWidth', 2);

    hold(ax, 'off');

    % 创建输出结构体
    output_data = struct();
    output_data.complex_matrix = input_data;
    output_data.magnitude_db = magnitude_db;
    output_data.max_value = max_val;
    output_data.min_value = min_val;
    output_data.mean_value = mean_val;
    output_data.name = '简单测试';
    output_data.timestamp = datetime('now');

    % 保存figure到缓存（直接作为顶层字段）
    output_data.cached_figure = fig;

    fprintf('\n✅ 简单测试脚本执行完成\n');
    fprintf('   包含元素：标题、轴标签、颜色条、网格、文字、数字\n');
    fprintf('   统计：最大值=%.2f, 最小值=%.2f, 平均值=%.2f\n', ...
            max_val, min_val, mean_val);

end

function value = getParam(params, name, default_value)
    if isfield(params, name)
        value = params.(name);
    else
        value = default_value;
    end
end
