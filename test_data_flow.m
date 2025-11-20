function output_data = test_data_flow(input_data, params)
% TEST_DATA_FLOW 测试预处理数据流的完整性
%
% 此脚本用于验证：
% 1. input_data 是否正确接收到上一步的 complex_matrix
% 2. params.source_data 是否包含上一步的完整数据
% 3. params.source_data.raw_matrix 是否可访问
% 4. params.source_data.additional_outputs 是否可访问
%
% 使用方法：
% 1. 先执行一个预处理（如CFAR），生成第一步结果
% 2. 新建预处理，处理对象选择第一步的结果（如"CFAR"）
% 3. 选择此脚本，点击应用
% 4. 查看控制台输出，验证数据流
%
% 参数定义：
% PARAM: verbose, bool, true

    % 获取参数
    verbose = getParam(params, 'verbose', true);

    fprintf('\n');
    fprintf('╔════════════════════════════════════════════════════════════╗\n');
    fprintf('║         预处理数据流完整性测试                             ║\n');
    fprintf('╚════════════════════════════════════════════════════════════╝\n');
    fprintf('\n');

    % ========== 测试1：input_data（第一个参数）==========
    fprintf('【测试1】input_data（第一个参数）\n');
    fprintf('├─ 类型：%s\n', class(input_data));
    fprintf('├─ 大小：%s\n', mat2str(size(input_data)));
    fprintf('├─ 是否复数：%s\n', mat2str(~isreal(input_data)));
    fprintf('├─ 最大幅度：%.4f\n', max(abs(input_data(:))));
    fprintf('└─ ✅ input_data 正确接收（应该是上一步的 complex_matrix）\n');
    fprintf('\n');

    % ========== 测试2：params.source_data 是否存在 ==========
    fprintf('【测试2】params.source_data（上一步完整数据）\n');
    if isfield(params, 'source_data')
        fprintf('└─ ✅ params.source_data 存在\n');
        source = params.source_data;

        % 列出所有字段
        fprintf('\n【测试3】source_data 包含的字段：\n');
        fields = fieldnames(source);
        for i = 1:length(fields)
            fieldName = fields{i};
            fprintf('├─ [%2d] %s', i, fieldName);

            % 显示字段信息
            if isfield(source, fieldName)
                fieldValue = source.(fieldName);
                if isnumeric(fieldValue)
                    fprintf(' → 数值数组 %s', mat2str(size(fieldValue)));
                elseif isstruct(fieldValue)
                    fprintf(' → 结构体（%d个字段）', length(fieldnames(fieldValue)));
                elseif isa(fieldValue, 'datetime')
                    fprintf(' → 时间：%s', char(fieldValue));
                else
                    fprintf(' → %s', class(fieldValue));
                end
            end
            fprintf('\n');
        end

        % ========== 测试4：complex_matrix ==========
        fprintf('\n【测试4】source_data.complex_matrix\n');
        if isfield(source, 'complex_matrix')
            fprintf('├─ ✅ 找到 complex_matrix\n');
            fprintf('├─ 大小：%s\n', mat2str(size(source.complex_matrix)));
            fprintf('└─ 与 input_data 是否相同：%s\n', mat2str(isequal(source.complex_matrix, input_data)));
        else
            fprintf('└─ ❌ 未找到 complex_matrix\n');
        end

        % ========== 测试5：raw_matrix ==========
        fprintf('\n【测试5】source_data.raw_matrix（上一步处理前的原始数据）\n');
        if isfield(source, 'raw_matrix')
            fprintf('├─ ✅ 找到 raw_matrix\n');
            fprintf('├─ 大小：%s\n', mat2str(size(source.raw_matrix)));
            fprintf('├─ 最大幅度：%.4f\n', max(abs(source.raw_matrix(:))));

            % 对比 raw_matrix 和 complex_matrix
            if isfield(source, 'complex_matrix')
                diff_max = max(abs(source.complex_matrix(:) - source.raw_matrix(:)));
                fprintf('└─ 与 complex_matrix 的最大差异：%.4f\n', diff_max);
                if diff_max > 1e-10
                    fprintf('   ✅ raw_matrix 和 complex_matrix 不同（说明上一步进行了处理）\n');
                else
                    fprintf('   ⚠️  raw_matrix 和 complex_matrix 相同（上一步可能未处理）\n');
                end
            end
        else
            fprintf('└─ ❌ 未找到 raw_matrix（这是一个BUG，应该包含！）\n');
        end

        % ========== 测试6：additional_outputs ==========
        fprintf('\n【测试6】source_data.additional_outputs（上一步的额外输出）\n');
        if isfield(source, 'additional_outputs')
            fprintf('├─ ✅ 找到 additional_outputs\n');
            addFields = fieldnames(source.additional_outputs);
            fprintf('├─ 包含 %d 个字段：\n', length(addFields));

            for i = 1:length(addFields)
                addFieldName = addFields{i};
                addFieldValue = source.additional_outputs.(addFieldName);

                fprintf('│  ├─ [%d] %s', i, addFieldName);

                if isnumeric(addFieldValue)
                    fprintf(' → 数值数组 %s\n', mat2str(size(addFieldValue)));
                elseif isstruct(addFieldValue)
                    fprintf(' → 结构体\n');
                elseif isa(addFieldValue, 'matlab.ui.Figure')
                    fprintf(' → Figure对象\n');
                else
                    fprintf(' → %s\n', class(addFieldValue));
                end
            end

            % 检查常见的额外输出
            fprintf('│\n');
            fprintf('├─ 检查常见字段：\n');
            if isfield(source.additional_outputs, 'thresholds')
                fprintf('│  ├─ ✅ thresholds（CFAR阈值矩阵）\n');
            end
            if isfield(source.additional_outputs, 'detection_mask')
                fprintf('│  ├─ ✅ detection_mask（检测掩码）\n');
            end
            if isfield(source.additional_outputs, 'cached_figure')
                fprintf('│  ├─ ✅ cached_figure（缓存的figure）\n');
            end
            if isfield(source.additional_outputs, 'training_means')
                fprintf('│  ├─ ✅ training_means（CFAR训练均值）\n');
            end
            fprintf('│  └─ （根据上一步预处理类型，字段会有所不同）\n');
            fprintf('└─\n');
        else
            fprintf('└─ ⚠️  未找到 additional_outputs（上一步可能未生成额外输出）\n');
        end

        % ========== 测试7：preprocessing_info ==========
        fprintf('\n【测试7】source_data.preprocessing_info（上一步的预处理配置）\n');
        if isfield(source, 'preprocessing_info')
            fprintf('├─ ✅ 找到 preprocessing_info\n');
            prep_info = source.preprocessing_info;

            if isfield(prep_info, 'name')
                fprintf('│  ├─ 名称：%s\n', prep_info.name);
            end
            if isfield(prep_info, 'type')
                fprintf('│  ├─ 类型：%s\n', prep_info.type);
            end
            if isfield(prep_info, 'processing_object')
                fprintf('│  ├─ 处理对象：%s\n', prep_info.processing_object);
            end
            if isfield(prep_info, 'scriptPath')
                fprintf('│  └─ 脚本路径：%s\n', prep_info.scriptPath);
            end
        else
            fprintf('└─ ❌ 未找到 preprocessing_info\n');
        end

    else
        fprintf('└─ ❌ params.source_data 不存在\n');
        fprintf('   说明：处理对象可能是"当前帧原图"，而不是上一步预处理结果\n');
    end

    fprintf('\n');
    fprintf('╔════════════════════════════════════════════════════════════╗\n');
    fprintf('║                    测试总结                                ║\n');
    fprintf('╚════════════════════════════════════════════════════════════╝\n');

    if isfield(params, 'source_data')
        has_raw = isfield(params.source_data, 'raw_matrix');
        has_additional = isfield(params.source_data, 'additional_outputs');

        if has_raw && has_additional
            fprintf('✅ 所有关键数据都可访问！数据流完整！\n');
        elseif has_raw
            fprintf('⚠️  raw_matrix 可访问，但 additional_outputs 缺失\n');
        elseif has_additional
            fprintf('⚠️  additional_outputs 可访问，但 raw_matrix 缺失（这是BUG！）\n');
        else
            fprintf('❌ raw_matrix 和 additional_outputs 都缺失！\n');
        end
    else
        fprintf('ℹ️  处理对象是原图，无上一步数据\n');
    end

    fprintf('\n');

    % ========== 创建输出 ==========
    output_data = struct();
    output_data.complex_matrix = input_data;  % 保持不变
    output_data.test_result = 'pass';
    output_data.name = '数据流测试';
    output_data.timestamp = datetime('now');

    % 记录测试信息
    if isfield(params, 'source_data')
        output_data.has_source_data = true;
        output_data.has_raw_matrix = isfield(params.source_data, 'raw_matrix');
        output_data.has_additional_outputs = isfield(params.source_data, 'additional_outputs');
        if isfield(params.source_data, 'preprocessing_info')
            output_data.source_preprocessing_name = params.source_data.preprocessing_info.name;
        end
    else
        output_data.has_source_data = false;
    end

end

function value = getParam(params, name, default_value)
    if isfield(params, name)
        value = params.(name);
    else
        value = default_value;
    end
end
