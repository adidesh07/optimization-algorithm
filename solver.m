clear all;
clc;

% Code for calculating IBFS for optimization in transportation problem
% Using Vogel's Approximation Method

% A => Input Transportation Matrix
% Last row and column should be demand and supply values respectively
% Uncomment required A matrix for sample problems

% Sample problem 1
% Solution ==> (250*2)+(300*1)+(200*2)+(50*3)+(250*3)+(150*5) = 2850
% A = [
%     3 1 7 4 300;
%     2 6 5 9 400;
%     8 3 3 2 500;
%     250 350 400 200 1200;
%     ];

% Sample problem 2
% Solution ==> (8*8)+(19*5)+(20*10)+(10*2)+(40*7)+(60*2) = 779
A = [
    19 30 50 10 7;
    70 30 40 60 9;
    40 8 70 20 18;
    5 8 7 14 34;
    ];


demand = A(end, 1:end-1);
supply = A(1:end-1, end);
cost = A(1:end-1, 1:end-1);

% Initializing variables
row_diff = zeros([length(supply) 1]); % Difference row vector
col_diff = zeros([1 length(demand)]); % Difference column vector
[x, y] = size(cost); % Used for iterations
allocations = []; % Ordered list of allocations
allocated_costs = []; % Ordered list of costs
dgen = 0; % Degeneracy flag


while x >= 1 || y >= 1
    
    % Last iteration: when cost => single column/row vector
    if x == 1 || y == 1
        n = length(cost);
        while i <= n
            min_cost = min(cost);
            min_cost_index = find(cost == min_cost);

            if x == 1
                allocations(end+1) = demand(min_cost_index);
                supply = supply - demand(min_cost_index);
                demand(min_cost_index) = [];
            else
                allocations(end+1) = supply(min_cost_index);
                demand = demand - supply(min_cost_index);
                supply(min_cost_index) = [];
            end
            
            allocated_costs(end+1) = cost(min_cost_index);
            cost(min_cost_index) = [];
            i = i + 1;    
        end
        
        allocations(end+1) = demand;
        allocated_costs(end+1) = cost;        
        break
    end
    
    
    % Calculate difference between lease and second to least values
    % Set these values in row_diff and col_diff respectively
    for i = 1:length(demand)
        col = sort(cost(:, i));
        if length(col) >= 2
            col_diff(i) = col(2) - col(1);
        else
            col_diff(i) = col(1);
        end
    end

    for j = 1:length(supply)
        row = sort(cost(j, :));
        if length(row) >= 2
            row_diff(j) = row(2) - row(1);
        else
            row_diff(j) = row(1);
        end
    end
    
    
    % Select maximum value from both difference vectors
    row_max = max(row_diff);
    col_max = max(col_diff);

    % Flag to check if resulting index is from row_diff or col_diff
    is_col_diff_index = 0;

    if col_max >= row_max
        max_index = find(col_diff == col_max, 1);
        is_col_diff_index = 1;
    else
        max_index = find(row_diff == row_max, 1);

    end
    
    supply_temp_index = 0;
    demand_temp_index = 0;

    % Find min cost corresponding to selected max difference
    if is_col_diff_index
        min_cost = min(cost(:, max_index));
        min_cost_index = find(cost(:, max_index) == min_cost);
        temp_supply = supply(min_cost_index);
        temp_demand = demand(max_index);
        supply_temp_index = min_cost_index;
        demand_temp_index = max_index;
    else
        min_cost = min(cost(max_index, :));
        min_cost_index = find(cost(max_index, :) == min_cost);
        temp_demand = demand(min_cost_index);
        temp_supply = supply(max_index);
        supply_temp_index = max_index;
        demand_temp_index = min_cost_index;
    end

    allocated_costs(end+1) = cost(supply_temp_index, demand_temp_index);
    
    % Remove selected row/column accordingly if demand satisfies supply
    if temp_supply > temp_demand
        supply(supply_temp_index) =  temp_supply - temp_demand;
        demand(demand_temp_index) = [];
        cost(:, demand_temp_index) = [];
        col_diff(demand_temp_index) = [];
        allocations(end+1) = temp_demand;
        y = y - 1;
    elseif temp_supply < temp_demand
        demand(demand_temp_index) = temp_demand - temp_supply;
        supply(supply_temp_index) = [];
        cost(supply_temp_index, :) = [];
        row_diff(demand_temp_index) = [];
        allocations(end+1) = temp_supply;
        x = x - 1;        
    else
        % Degeneracy in the solution
        dgen = 1;
        break
    end
    
end

if dgen
    disp('Degeneracy detected. Calculation in case of degeneracy not included in this algorithm.');
else
    disp("Ordered allocations list: ");
    disp(allocations);
    disp("Ordered costs for each allocation:");
    disp(allocated_costs);
    disp('----');
    disp("IBFS:");
    ibfs = allocations .* allocated_costs;
    disp(sum(ibfs));
end