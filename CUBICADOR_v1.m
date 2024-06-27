function CUBICADOR_v1()
    fig = uifigure('Name', 'Software de Cubicaciones', 'Position', [100 100 400 700]);

    % Título principal
    titleLabel = uilabel(fig, 'Position', [100, 650, 200, 30], 'Text', 'Software de Cubicaciones', 'FontSize', 16, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');

    % Seleccionar Tipo de Material
    lblMaterial = uilabel(fig, 'Position', [50, 600, 200, 22], 'Text', 'Seleccionar Tipo de Material', 'FontSize', 12, 'FontWeight', 'bold');
    ddMaterial = uidropdown(fig, 'Position', [50, 570, 300, 22], 'Items', {'Eliga el material', 'Base Granular', 'Hormigón', 'Asfalto'}, 'Value', 'Eliga el material', 'ValueChangedFcn', @(dd, event) selectMaterialCallback(dd));

    % Seleccionar Espesor de la Base
    lblBaseThickness = uilabel(fig, 'Position', [50, 530, 200, 22], 'Text', 'Espesor de la Base (m)', 'FontSize', 12, 'FontWeight', 'bold');
    baseThicknessField = uieditfield(fig, 'numeric', 'Position', [50, 500, 100, 22], 'Value', 0.3);

    % Seleccionar Ancho de la Base
    lblBaseWidth = uilabel(fig, 'Position', [50, 460, 200, 22], 'Text', 'Ancho de la Base (m)', 'FontSize', 12, 'FontWeight', 'bold');
    baseWidthField = uieditfield(fig, 'numeric', 'Position', [50, 430, 100, 22], 'Value', 5.0);

    % Seleccionar Ancho de la Capa Superior
    lblSupWidth = uilabel(fig, 'Position', [50, 400, 200, 22], 'Text', 'Ancho de la Capa Superior (m)', 'FontSize', 12, 'FontWeight', 'bold');
    supWidthField = uieditfield(fig, 'numeric', 'Position', [50, 370, 100, 22], 'Value', 4.0);

    % Importar Datos Topográficos
    lblImport = uilabel(fig, 'Position', [50, 330, 200, 22], 'Text', 'Importar Datos Topográficos', 'FontSize', 12, 'FontWeight', 'bold');
    btnImport = uibutton(fig, 'Position', [50, 300, 100, 22], 'Text', 'Importar', 'ButtonPushedFcn', @(btn, event) importCallback());
    lblFile = uilabel(fig, 'Position', [50, 270, 300, 22], 'Text', 'Ningún archivo seleccionado', 'FontSize', 10, 'FontAngle', 'italic');

    % Calcular Volumen
    lblCalculate = uilabel(fig, 'Position', [50, 230, 200, 22], 'Text', 'Calcular Volumen', 'FontSize', 12, 'FontWeight', 'bold');
    btnCalculate = uibutton(fig, 'Position', [50, 200, 100, 22], 'Text', 'Calcular', 'ButtonPushedFcn', @(btn, event) calculateCallback());

    % Visualizar Resultados
    lblVisualize = uilabel(fig, 'Position', [50, 160, 200, 22], 'Text', 'Visualizar Resultados', 'FontSize', 12, 'FontWeight', 'bold');
    btnVisualize = uibutton(fig, 'Position', [50, 130, 100, 22], 'Text', 'Visualizar', 'ButtonPushedFcn', @(btn, event) visualizeCallback());

    % Generar Reporte
    lblReport = uilabel(fig, 'Position', [50, 90, 200, 22], 'Text', 'Generar Reporte', 'FontSize', 12, 'FontWeight', 'bold');
    btnReport = uibutton(fig, 'Position', [50, 60, 100, 22], 'Text', 'Generar', 'ButtonPushedFcn', @(btn, event) reportCallback());

    % Callback functions
    function importCallback()
        [file, path] = uigetfile({'*.csv';'*.xls';'*.txt'}, 'Seleccione un archivo');
        if isequal(file, 0)
            lblFile.Text = 'Ningún archivo seleccionado';
            return;
        end
        fullFilePath = fullfile(path, file);
        data = importTopographicData(fullFilePath, file(end-2:end));
        assignin('base', 'topoData', data); % Guardar en el workspace
        lblFile.Text = ['Archivo seleccionado: ', file]; % Actualizar la etiqueta con el nombre del archivo
    end

    function calculateCallback()
        if evalin('base', 'exist(''topoData'', ''var'')') ~= 1
            uialert(fig, 'Por favor importe los datos topográficos primero.', 'Error');
            return;
        end
        data = evalin('base', 'topoData');
        if evalin('base', 'exist(''selectedMaterial'', ''var'')') ~= 1
            uialert(fig, 'Por favor seleccione un material.', 'Error');
            return;
        end
        % Obtener el material seleccionado, espesor y ancho de la carretera
        materialType = evalin('base', 'selectedMaterial'); % Obtener el material seleccionado
        if strcmp(materialType, 'Eliga el material')
            uialert(fig, 'Por favor seleccione un material válido.', 'Error');
            return;
        end
        baseThickness = baseThicknessField.Value; % Obtener el espesor de la base ingresado por el usuario
        baseWidth = baseWidthField.Value; % Obtener el ancho de la base ingresado por el usuario
        supWidth = supWidthField.Value; % Obtener el ancho de la capa superior ingresado por el usuario
        
        % Determinar el espesor de la capa superior según el material seleccionado
        switch materialType
            case 'Base Granular'
                supThickness = 0.3;
            case 'Hormigón'
                supThickness = 0.1;
            case 'Asfalto'
                supThickness = 0.2;
            otherwise
                supThickness = 0;
        end
        
        % Realizar cálculos de volumen
        [volumen_corte_total, volumen_relleno_total, volumen_infraestructura_total] = calculateVolumes(data, baseWidth, baseThickness, supWidth, supThickness);
        assignin('base', 'calculatedVolumeCorte', volumen_corte_total); % Guardar en el workspace
        assignin('base', 'calculatedVolumeRelleno', volumen_relleno_total); % Guardar en el workspace
        assignin('base', 'calculatedVolumeInfra', volumen_infraestructura_total); % Guardar en el workspace
    end

    function visualizeCallback()
        if evalin('base', 'exist(''topoData'', ''var'')') ~= 1
            uialert(fig, 'Por favor importe los datos topográficos primero.', 'Error');
            return;
        end
        data = evalin('base', 'topoData');
        if evalin('base', 'exist(''calculatedVolumeCorte'', ''var'')') ~= 1
            uialert(fig, 'Por favor calcule los volúmenes primero.', 'Error');
            return;
        end
        volumen_corte_total = evalin('base', 'calculatedVolumeCorte');
        volumen_relleno_total = evalin('base', 'calculatedVolumeRelleno');
        volumen_infraestructura_total = evalin('base', 'calculatedVolumeInfra');
        visualizeResults(data.Profile1, data.Profile2, data.Rasante, volumen_corte_total, volumen_relleno_total, volumen_infraestructura_total);
    end

    function reportCallback()
        if evalin('base', 'exist(''calculatedVolumeCorte'', ''var'')') ~= 1
            uialert(fig, 'Por favor calcule los volúmenes primero.', 'Error');
            return;
        end
        volumen_corte_total = evalin('base', 'calculatedVolumeCorte');
        volumen_relleno_total = evalin('base', 'calculatedVolumeRelleno');
        volumen_infraestructura_total = evalin('base', 'calculatedVolumeInfra');
        [file, path] = uiputfile('report.txt', 'Guardar Reporte');
        if isequal(file, 0)
            return;
        end
        fullFilePath = fullfile(path, file);
        generateReport(volumen_corte_total, volumen_relleno_total, volumen_infraestructura_total, fullFilePath);
    end

    function selectMaterialCallback(dd)
        selectedMaterial = dd.Value;
        assignin('base', 'selectedMaterial', selectedMaterial); % Guardar en el workspace
    end
end

% Función para importar datos topográficos
function data = importTopographicData(filename, fileType)
    switch fileType
        case 'csv'
            data = readtable(filename, 'Delimiter', ',');
        case 'xls'
            data = readtable(filename, 'Sheet', 1);
        case 'txt'
            data = readtable(filename, 'Delimiter', '\t');
        otherwise
            error('Tipo de archivo no soportado.');
    end

    % Verificar que las columnas esperadas existan
    expectedColumns = {'Profile1', 'Profile2', 'Rasante', 'Distance'};
    if ~all(ismember(expectedColumns, data.Properties.VariableNames))
        error('El archivo de datos no contiene las columnas necesarias: Profile1, Profile2, Rasante, Distance');
    end

    % Imprimir los datos importados para verificar
    disp('Datos importados:');
    disp(data);
end

% Función para calcular volúmenes
function [volumen_corte_total, volumen_relleno_total, volumen_infraestructura_total] = calculateVolumes(data, ancho_base, espesor_base, ancho_capa_superior, espesor_capa_superior)
    % Extraer los datos necesarios de la tabla importada
    y1 = data.Profile1; % Alturas del primer perfil
    y2 = data.Profile2; % Alturas del segundo perfil
    rasante = data.Rasante; % Alturas de la rasante en cada sección
    d = data.Distance; % Distancia entre las secciones transversales

    % Número de secciones
    n = length(y1);

    % Verificar que los vectores de entrada tengan la misma longitud
    if length(y1) ~= length(y2) || length(y1) ~= length(rasante) || length(y1) ~= length(d)
        error('Los vectores de alturas deben tener la misma longitud.');
    end

    % Inicializar los volúmenes
    volumen_corte_total = 0;
    volumen_relleno_total = 0;
    volumen_infraestructura_total = 0;

    for i = 1:n-1
        % Altura promedio en la sección actual
        h_promedio1 = (y1(i) + y1(i+1)) / 2;
        h_promedio2 = (y2(i) + y2(i+1)) / 2;
        
        % Altura promedio del perfil
        h_promedio_perfil = (h_promedio1 + h_promedio2) / 2;
        
        % Altura promedio de la rasante en la sección actual
        h_rasante = (rasante(i) + rasante(i+1)) / 2;
        
        % Calcular volumen de corte y relleno
        dif_altura = h_rasante - h_promedio_perfil;
        if dif_altura < 0
            % Corte
            volumen_corte = abs(dif_altura) * d(i) * ancho_base;
            volumen_corte_total = volumen_corte_total + volumen_corte;
        else
            % Relleno
            volumen_relleno = abs(dif_altura) * d(i) * ancho_base;
            volumen_relleno_total = volumen_relleno_total + volumen_relleno;
        end
        
        % Calcular el volumen de la infraestructura de la carretera
        volumen_base = espesor_base * d(i) * ancho_base;
        volumen_capa_superior = espesor_capa_superior * d(i) * ancho_capa_superior;
        volumen_infraestructura = volumen_base + volumen_capa_superior;
        
        % Sumar el volumen de la infraestructura
        volumen_infraestructura_total = volumen_infraestructura_total + volumen_infraestructura;
    end
end

function visualizeResults(profile1, profile2, rasante, volumen_corte_total, volumen_relleno_total, volumen_infraestructura_total)
    % Verificar que los perfiles tengan la misma longitud
    if length(profile1) ~= length(profile2) || length(profile1) ~= length(rasante)
        error('Los perfiles no tienen la misma longitud.');
    end

    % Crear figura
    figure('Name', 'Resultados de Cubicaciones', 'NumberTitle', 'off', 'Position', [100, 100, 1000, 600]);

    % Subplot 1: Gráfico 2D de los perfiles
    subplot(2, 2, 1);
    plot(profile1, 'b', 'LineWidth', 1.5, 'DisplayName', 'Terreno Natural 1');
    hold on;
    plot(rasante, 'r--', 'LineWidth', 1.5, 'DisplayName', 'Rasante de la Carretera');
    plot(profile2, 'g', 'LineWidth', 1.5, 'DisplayName', 'Terreno Natural 2');
    title('Perfiles Topográficos', 'FontSize', 14, 'FontWeight', 'bold');
    legend('show');
    xlabel('Punto', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('Elevación (m)', 'FontSize', 12, 'FontWeight', 'bold');
    grid on;

    % Subplot 2: Gráfico 3D de los perfiles
    subplot(2, 2, 2);
    [X, Y] = meshgrid(1:length(profile1), 1:3);
    Z = [profile1'; rasante'; profile2'];
    surf(X, Y, Z, 'EdgeColor', 'none');
    hold on;
    plot3(1:length(rasante), 2*ones(size(rasante)), rasante, 'r--', 'LineWidth', 1.5, 'DisplayName', 'Rasante de la Carretera');
    plot3(1:length(profile1), ones(size(profile1)), profile1, 'b', 'LineWidth', 1.5, 'DisplayName', 'Terreno Natural 1');
    plot3(1:length(profile2), 3*ones(size(profile2)), profile2, 'g', 'LineWidth', 1.5, 'DisplayName', 'Terreno Natural 2');
    colormap jet;
    colorbar;
    title('Modelo 3D', 'FontSize', 14, 'FontWeight', 'bold');
    xlabel('Punto', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('Perfil', 'FontSize', 12, 'FontWeight', 'bold');
    zlabel('Elevación (m)', 'FontSize', 12, 'FontWeight', 'bold');
    grid on;

    % Resultados del cálculo
    subplot(2, 2, [3, 4]);
    axis off;
    text(0.1, 0.8, ['Volumen total de corte: ', num2str(volumen_corte_total), ' Metros Cubicos'], 'FontSize', 12, 'FontWeight', 'bold');
    text(0.1, 0.6, ['Volumen total de relleno: ', num2str(volumen_relleno_total), ' Metros Cubicos'], 'FontSize', 12, 'FontWeight', 'bold');
    text(0.1, 0.4, ['Volumen total de la infraestructura: ', num2str(volumen_infraestructura_total), ' Metros Cubicos'], 'FontSize', 12, 'FontWeight', 'bold');
    title('Resultados del Cálculo', 'FontSize', 14, 'FontWeight', 'bold');
end

% Función para generar reporte
function generateReport(volumen_corte_total, volumen_relleno_total, volumen_infraestructura_total, fullFilePath)
    fid = fopen(fullFilePath, 'w');
    fprintf(fid, 'Reporte de Volúmenes\n');
    fprintf(fid, '====================\n\n');
    fprintf(fid, 'Volumen total de corte: %.2f Metros Cubicos\n', volumen_corte_total);
    fprintf(fid, 'Volumen total de relleno: %.2f Metros Cubicos\n', volumen_relleno_total);
    fprintf(fid, 'Volumen total de la infraestructura: %.2f Metros Cubicos\n', volumen_infraestructura_total);
    fclose(fid);
    disp('Reporte generado.');
end
