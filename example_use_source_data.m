function output_data = example_use_source_data(input_data, params)
% EXAMPLE_USE_SOURCE_DATA 演示如何访问上一步预处理结果的完整数据
%
% 此脚本演示当处理对象是上一步预处理结果时，如何访问：
% - input_data: 上一步的 complex_matrix（默认传入）
% - params.source_data.raw_matrix: 上一步处理前的原始数据
% - params.source_data.additional_outputs: 上一步的额外输出（如CFAR阈值、检测掩码等）
% - params.source_data.其他字段: 上一步的任意字段
%
% 使用场景示例：
% 1. 处理对象选择"CFAR"，可以访问CFAR的阈值矩阵来做自适应处理
% 2. 处理对象选择"检测"，可以访问检测掩码来做进一步分析
% 3. 处理对象选择自定义预处理，可以访问其cached_figure等
%
% 参数定义：
% PARAM: use_raw_matrix, bool, false
% PARAM: show_source_info, bool, true

    % 获取参数
    use_raw_matrix = getParam(params, 'use_raw_matrix', false);
    show_source_info = getParam(params, 'show_source_info', true);

    % 确保输入为数值类型
    if ~isnumeric(input_data)
        error('输入数据必须是数值类型');
    end

    % 转换为double类型
    input_data = double(input_data);

    fprintf('\n========== 示例：访问上一步预处理数据 ==========\n');

    % ========== 演示：访问上一步的完整数据 ==========
    if isfield(params, 'source_data')
        fprintf('✅ 检测到上一步预处理数据（params.source_data）\n');
        source = params.source_data;

        % 显示上一步数据的可用字段
        if show_source_info
            fprintf('\n上一步数据包含的字段：\n');
            fields = fieldnames(source);
            for i = 1:length(fields)
                fieldName = fields{i};
                fieldValue = source.(fieldName);
                if isnumeric(fieldValue)
                    fprintf('  - %s: [%s] 数值数组\n', fieldName, mat2str(size(fieldValue)));
                elseif isstruct(fieldValue)
                    fprintf('  - %s: 结构体\n', fieldName);
                    subFields = fieldnames(fieldValue);
                    for j = 1:min(3, length(subFields))
                        fprintf('      └─ %s\n', subFields{j});
                    end
                    if length(subFields) > 3
                        fprintf('      └─ ... 还有 %d 个字段\n', length(subFields) - 3);
                    end
                else
                    fprintf('  - %s: %s\n', fieldName, class(fieldValue));
                end
            end
        end

        % 示例1：访问 raw_matrix（上一步处理前的原始数据）
        if isfield(source, 'raw_matrix')
            fprintf('\n✅ 找到 raw_matrix（上一步处理前的原始数据）\n');
            raw_matrix = source.raw_matrix;
            fprintf('   大小：%s\n', mat2str(size(raw_matrix)));

            if use_raw_matrix
                fprintf('   → 使用 raw_matrix 作为输入进行处理\n');
                input_data = raw_matrix;
            end
        else
            fprintf('\n❌ 未找到 raw_matrix\n');
        end

        % 示例2：访问 additional_outputs（上一步的额外输出）
        if isfield(source, 'additional_outputs')
            fprintf('\n✅ 找到 additional_outputs（上一步的额外输出）\n');
            additional = source.additional_outputs;

            % 检查常见的额外输出字段
            if isfield(additional, 'thresholds')
                fprintf('   → CFAR阈值矩阵: %s\n', mat2str(size(additional.thresholds)));
            end
            if isfield(additional, 'detection_mask')
                fprintf('   → 检测掩码: %s\n', mat2str(size(additional.detection_mask)));
            end
            if isfield(additional, 'cached_figure')
                fprintf('   → 缓存的figure: %s\n', class(additional.cached_figure));
            end

            % 显示所有额外输出字段
            addFields = fieldnames(additional);
            fprintf('   额外输出包含 %d 个字段：', length(addFields));
            for i = 1:length(addFields)
                fprintf(' %s', addFields{i});
            end
            fprintf('\n');
        else
            fprintf('\n❌ 未找到 additional_outputs\n');
        end

        % 示例3：访问 preprocessing_info（上一步的预处理配置）
        if isfield(source, 'preprocessing_info')
            fprintf('\n✅ 找到 preprocessing_info（上一步的预处理配置）\n');
            prep_info = source.preprocessing_info;
            if isfield(prep_info, 'name')
                fprintf('   上一步预处理名称：%s\n', prep_info.name);
            end
            if isfield(prep_info, 'type')
                fprintf('   上一步预处理类型：%s\n', prep_info.type);
            end
        end
    else
        fprintf('ℹ️  未检测到上一步预处理数据\n');
        fprintf('   处理对象可能是"当前帧原图"\n');
    end

    fprintf('===============================================\n\n');

    % ========== 实际处理逻辑 ==========
    % 这里只做简单的幅度计算作为示例
    magnitude = abs(input_data);
    magnitude_db = 20 * log10(magnitude + eps);

    % 创建输出结构体
    output_data = struct();
    output_data.complex_matrix = input_data;  % 必需字段
    output_data.magnitude_db = magnitude_db;
    output_data.max_value = max(magnitude_db(:));
    output_data.mean_value = mean(magnitude_db(:));
    output_data.name = '示例输出';
    output_data.timestamp = datetime('now');

    % 如果访问了上一步数据，可以将相关信息保存到输出中
    if isfield(params, 'source_data')
        output_data.source_preprocessing = params.source_data.preprocessing_info.name;
        fprintf('✅ 已记录上一步预处理信息到输出\n');
    end

end

function value = getParam(params, name, default_value)
    % 辅助函数：从params结构体中获取参数值
    if isfield(params, name)
        value = params.(name);
    else
        value = default_value;
    end
end
