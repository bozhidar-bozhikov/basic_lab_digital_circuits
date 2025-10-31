data = readtable('one_shot_results.csv');

disp('Data loaded:');
disp(head(data));
disp('Size of data:');
disp(size(data));

if iscell(data.Trigger_i)
    trigger_i = cellfun(@(x) str2double(strrep(x, '''', '')), data.Trigger_i);
    pulse_out = cellfun(@(x) str2double(strrep(x, '''', '')), data.Pulse_o);
    reset_sig = cellfun(@(x) str2double(strrep(x, '''', '')), data.Reset);
elseif ischar(data.Trigger_i(1)) || isstring(data.Trigger_i(1))
    trigger_i = str2double(strrep(string(data.Trigger_i), "'", ""));
    pulse_out = str2double(strrep(string(data.Pulse_o), "'", ""));
    reset_sig = str2double(strrep(string(data.Reset), "'", ""));
else
    trigger_i = data.Trigger_i;
    pulse_out = data.Pulse_o;
    reset_sig = data.Reset;
end

time_ns = data.Time_ns;

disp('Any NaN in trigger_i?');
disp(any(isnan(trigger_i)));
disp('Any NaN in pulse_out?');
disp(any(isnan(pulse_out)));

figure;
subplot(3,1,1);
stairs(time_ns, reset_sig, 'g', 'LineWidth', 2);
ylabel('Reset');
title('One-Shot Circuit Simulation Results');
grid on;
ylim([-0.1 1.1]);
yticks([0 1]);

subplot(3,1,2);
stairs(time_ns, trigger_i, 'b', 'LineWidth', 2);
ylabel('Trigger Input');
grid on;
ylim([-0.1 1.1]);
yticks([0 1]);

subplot(3,1,3);
stairs(time_ns, pulse_out, 'r', 'LineWidth', 2);
ylabel('Pulse Output');
xlabel('Time (ns)');
grid on;
ylim([-0.1 1.1]);
yticks([0 1]);