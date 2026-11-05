# Restaurant Operations & Declarative Constraint-Satisfaction Engine

A dual-paradigm operational modeling system built in **SWI-Prolog** and **Haskell**. The project combines a declarative constraint-satisfaction solver in Prolog—handling multi-table restaurant reservation scheduling, staff-capacity validation, recipe ingredient aggregation, and CSV serialization—with a pure functional supply-chain and hierarchical expense analytics engine in Haskell.

## Core Capabilities

- **Declarative Constraint-Satisfaction Scheduling (`Prolog`):** Utilizes nondeterministic backtracking and unification (`schedule_all_reservations/2`, `check_staff/3`) to assign dining groups across available dates, preferred time slots, table capacities, and daily staffing ceilings while preventing double-bookings.
- **Recursive Recipe & Ingredient Aggregation (`Prolog`):** Traverses multi-course group orders (`group_ingredients/2`, `needed_ingredients/2`) to aggregate daily raw ingredient requirements and serialize operational schedules directly to `.csv` files (`write_reservations_to_csv/2`, `write_ingredients_to_csv/2`).
- **Pure Functional Supply Lead-Time Calculation (`Haskell`):** Models nested recipes (`SimpleIngredient` vs. recursive `Recipe` trees) and date arithmetic (`calculateDeliveryDates`, `summarizeAllDeliveries`) to compute exact procurement dates, aggregate item quantities, and sort multi-day supplier deliveries without mutable state.
- **Hierarchical Expense Tree Analytics (`Haskell`):** Evaluates recursive Algebraic Data Types (`Expense = Item | Category`) using higher-order functions (`map`, `sum`) to compute total category expenditures (`calculateTotalExpenses`) and leaf-item counts (`countCategoryItems).
