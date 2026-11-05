-- Part A: Date Arithmetic & Lead-Time Delivery Calculation
month_num :: Month -> Int
month_num x
    | x == Jan = 1  | x == Feb = 2  | x == Mar = 3  | x == Apr = 4
    | x == May = 5  | x == Jun = 6  | x == Jul = 7  | x == Aug = 8
    | x == Sep = 9  | x == Oct = 10 | x == Nov = 11 | otherwise = 12

num_month :: Int -> Month
num_month x
    | x == 1 = Jan  | x == 2 = Feb  | x == 3 = Mar  | x == 4 = Apr
    | x == 5 = May  | x == 6 = Jun  | x == 7 = Jul  | x == 8 = Aug
    | x == 9 = Sep  | x == 10 = Oct | x == 11 = Nov | otherwise = Dec

days_month :: Month -> Int
days_month x
    | x == Feb = 28
    | x == Apr || x == Jun || x == Sep || x == Nov = 30
    | otherwise = 31

subtract_days :: Date -> Int -> Date
subtract_days (d, m, y) n
    | d > n = (d - n, m, y)
    | otherwise = subtract_days (days_month pmonth, pmonth, pyear) (n - d)
    where
        pmonth = num_month (if month_num m == 1 then 12 else month_num m - 1)
        pyear  = if month_num m == 1 then y - 1 else y

get_info :: String -> [(String, Int, Price)] -> (Int, Price)
get_info name ((n, d, p):t)
    | name == n = (d, p)
    | otherwise = get_info name t

calculateDeliveryDates :: Date -> [Ingredient] -> [(Date, (String, Price))]
calculateDeliveryDates _ [] = []
calculateDeliveryDates date (SimpleIngredient name : t) =
    (subtract_days date d, (name, p)) : calculateDeliveryDates date t
    where (d, p) = get_info name ingredient_info
calculateDeliveryDates date (Recipe _ res : t) =
    calculateDeliveryDates date res ++ calculateDeliveryDates date t

-- Part B: Multi-Day Delivery Summarization & Lexicographical Aggregation
summarizeAllDeliveries :: [Date] -> [Delivery]
summarizeAllDeliveries targetDates = buildDeliveries rawItems []
    where rawItems = getRawItems targetDates shopping_list

getRawItems :: [Date] -> [(Date, [Ingredient])] -> [(Date, (String, Price))]
getRawItems _ [] = []
getRawItems targets ((d, ings):rest) =
    if containsDate d targets
    then calculateDeliveryDates d ings ++ getRawItems targets rest
    else getRawItems targets rest

containsDate :: Date -> [Date] -> Bool
containsDate _ [] = False
containsDate d (x:xs) = (d == x) || containsDate d xs

buildDeliveries :: [(Date, (String, Price))] -> [Delivery] -> [Delivery]
buildDeliveries [] acc = acc
buildDeliveries (item:rest) acc = buildDeliveries rest (insertDelivery item acc)

insertDelivery :: (Date, (String, Price)) -> [Delivery] -> [Delivery]
insertDelivery (d, (name, price)) [] = [(d, [(name, 1, price)])]
insertDelivery (d, (name, price)) ((d2, supplies):rest)
    | d == d2       = (d2, insertSupply (name, price) supplies) : rest
    | isBefore d d2 = (d, [(name, 1, price)]) : (d2, supplies) : rest
    | otherwise     = (d2, supplies) : insertDelivery (d, (name, price)) rest

insertSupply :: (String, Price) -> [Supply] -> [Supply]
insertSupply (name, price) [] = [(name, 1, price)]
insertSupply (name, price) ((n, qty, p):rest)
    | name == n = (n, qty + 1, p + price) : rest
    | name < n  = (name, 1, price) : (n, qty, p) : rest
    | otherwise = (n, qty, p) : insertSupply (name, price) rest

isBefore :: Date -> Date -> Bool
isBefore (d1, m1, y1) (d2, m2, y2)
    | y1 /= y2 = y1 < y2
    | month_num m1 /= month_num m2 = month_num m1 < month_num m2
    | otherwise = d1 < d2

-- Part C: Expense Tree Construction
getDeliveryExpenses :: [Delivery] -> Expense
getDeliveryExpenses deliveries = Category "Food Supplies" (getAllExpenses deliveries)

getAllExpenses :: [Delivery] -> [Expense]
getAllExpenses [] = []
getAllExpenses ((date, supplies):t) = getDayExpenses date supplies ++ getAllExpenses t

getDayExpenses :: Date -> [Supply] -> [Expense]
getDayExpenses _ [] = []
getDayExpenses d ((name, _, price):t) = Item name price d : getDayExpenses d t

-- Part D: Modal Dish Frequency Analysis
mostPopularDish :: [String] -> [String]
mostPopularDish [] = []
mostPopularDish dishes = getNames (filterByLength (findMax grouped) grouped)
    where grouped = groupDishes (customSort dishes)

customSort :: [String] -> [String]
customSort [] = []
customSort (x:xs) = insertItem x (customSort xs)

insertItem :: String -> [String] -> [String]
insertItem item [] = [item]
insertItem item (y:ys) = if item <= y then item : y : ys else y : insertItem item ys

groupDishes :: [String] -> [[String]]
groupDishes [] = []
groupDishes [x] = [[x]]
groupDishes (x:y:ys) =
    if x == y then (x : head rest) : tail rest else [x] : rest
    where rest = groupDishes (y:ys)

findMax :: [[String]] -> Int
findMax [] = 0
findMax (x:xs) = max (length x) (findMax xs)

filterByLength :: Int -> [[String]] -> [[String]]
filterByLength _ [] = []
filterByLength targetSize (x:xs) =
    if length x == targetSize then x : filterByLength targetSize xs else filterByLength targetSize xs

getNames :: [[String]] -> [String]
getNames [] = []
getNames (x:xs) = head x : getNames xs

-- Part E & F: Hierarchical Expense Aggregation
calculateTotalExpenses :: Expense -> Price
calculateTotalExpenses (Item _ price _) = price
calculateTotalExpenses (Category _ expenses) = sum (map calculateTotalExpenses expenses)

countCategoryItems :: String -> Expense -> Int
countCategoryItems _ (Item _ _ _) = 0
countCategoryItems target (Category name xs)
    | target == name = countHelper (Category name xs)
    | otherwise      = sum (map (countCategoryItems target) xs)

-- Helper function to count leaf expense items once the target category is matched
countHelper :: Expense -> Int
countHelper (Item _  _ _ __ __ _ _) = 1
countHelper (Category _ xs) = sum (map countHelper xs)
