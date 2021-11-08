--Dim_Product
SELECT a.ProductID, a.Name ProductName, a.ProductNumber, a.MakeFlag, a.FinishedGoodsFlag, a.SafetyStockLevel, a.ReorderPoint, 
a.DaysToManufacture, a.ProductLine, a.Color, a.Class, a.Style, a.Size,
b.Name SubCategoryName, c.Name CategoryName, d.Name ProductModelName
FROM Production.Product a 
left join Production.ProductSubcategory b on a.ProductSubcategoryID=b.ProductSubcategoryID
left join Production.ProductCategory c on b.ProductCategoryID = c.ProductCategoryID
left join Production.ProductModel d on a.ProductModelID = d.ProductModelID

--Dim_Location
SELECT	LocationID,
	Name LocationName
FROM Production.Location
Dim_ScrapReason
SELECT ScrapReasonID,
	Name ScrapReasonName
FROM Production.ScrapReason

--Dim_TransactionType (Create new data)
 
--Fact_WorkOrder
SELECT ProductID, 
CAST(YEAR(StartDate) AS nvarchar) + RIGHT('0' + CAST(MONTH(StartDate) AS nvarchar),2) + RIGHT('0' + CAST(DAY(StartDate) AS nvarchar),2) StartDate,  
CAST(YEAR(EndDate) AS nvarchar) + RIGHT('0' + CAST(MONTH(EndDate) AS nvarchar),2) + RIGHT('0' + CAST(DAY(EndDate) AS nvarchar),2) EndDate,
ScrapReasonID, OrderQty, 
StockedQty, ScrappedQty
FROM Production.WorkOrder

--Fact_WorkOrderRouting
SELECT A.ProductID, A.LocationID,
	ISNULL(B.TotalPlannedCost, 0) AS TotalPlannedCost,
	ISNULL(B.TotalActualCost, 0) AS TotalActualCost, 
	ISNULL(B.TotalActualResourceHrs, 0) AS TotalActualHours, 
CAST(YEAR(A.ScheduledStartDate) AS nvarchar) + RIGHT('0' + CAST(MONTH(A.ScheduledStartDate) AS nvarchar),2)  + RIGHT('0' + CAST(DAY(a.ScheduledStartDate) AS nvarchar),2) ScheduledStartDate,
CAST(YEAR(A.ScheduledEndDate) AS nvarchar) + RIGHT('0' + CAST(MONTH(A.ScheduledEndDate) AS nvarchar),2)  + RIGHT('0' + CAST(DAY(a.ScheduledEndDate) AS nvarchar),2) ScheduledEndDate,
CAST(YEAR(A.ActualStartDate) AS nvarchar) + RIGHT('0' + CAST(MONTH(A.ActualStartDate) AS nvarchar),2)  + RIGHT('0' + CAST(DAY(a.ActualStartDate) AS nvarchar),2) ActualStartDate,
CAST(YEAR(A.ActualEndDate) AS nvarchar) + RIGHT('0' + CAST(MONTH(A.ActualEndDate) AS nvarchar),2)  + RIGHT('0' + CAST(DAY(a.ActualEndDate) AS nvarchar),2) ActualEndDate
FROM Production.WorkOrderRouting A LEFT JOIN 
	(SELECT WorkOrderID, 
		SUM(ActualResourceHrs) AS TotalActualResourceHrs,
		SUM(PlannedCost) AS TotalPlannedCost,
		SUM(ActualCost) AS TotalActualCost
	FROM Production.WorkOrderRouting 
	GROUP BY WorkOrderID) as B
	ON A.WorkOrderID = B.WorkOrderID

--Fact_ProductReview
SELECT a.ProductID,
a.ProductReviewID,
CAST(YEAR(a.ReviewDate) AS nvarchar) + RIGHT('0' + CAST(MONTH(a.ReviewDate) AS nvarchar),2) + RIGHT('0' + CAST(DAY(a.ReviewDate) AS nvarchar),2) ReviewDate, a.Rating, a.Comments
FROM Production.ProductReview a
left join Production.Product b on a.ProductID = b.ProductID

--Fact_Transaction
SELECT a.ProductID,
CAST(YEAR(a.TransactionDate) AS nvarchar) + RIGHT('0' + CAST(MONTH(a.TransactionDate) AS nvarchar),2)  + RIGHT('0' + CAST(DAY(a.TransactionDate) AS nvarchar),2) TransactionDate,   
a.TransactionType,
a.Quantity,  b.StandardCost, a.ActualCost, b.ListPrice
FROM  Production.TransactionHistory a 
join Production.Product b on a.ProductID = b.ProductID

--Fact_Inventory
SELECT a.ProductID, a.LocationID, 
Shelf, Bin, Quantity, 
CAST(YEAR(a.ModifiedDate) AS nvarchar) + RIGHT('0' + CAST(MONTH(a.ModifiedDate) AS nvarchar),2)  + RIGHT('0' + CAST(DAY(a.ModifiedDate) AS nvarchar),2) ModifiedDate  
FROM Production.ProductInventory a
left join Production.Product b on a.ProductID = b.ProductID
left join Production.Location c on a.LocationID = c.LocationID

