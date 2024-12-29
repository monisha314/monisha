-- Project Title: E-Commerce Customer Churn Analysis

-- Project Steps and Objectives --

USE ecomm;

select*from customer_churn;

-- Data Cleaning:
-- Handling Missing Values and Outliers:
-- ➢ Impute mean for the following columns, and round off to the nearest integer if
-- required: WarehouseToHome
set sql_safe_updates = 0;
set @mean_WarehouseToHome= (select round(avg(WarehouseToHome)) from  customer_churn);
-- Impute mean values
update customer_churn 
set WarehouseToHome = @mean_WarehouseToHome
where WarehouseToHome is Null;

select * from customer_churn where WarehouseToHome is Null ;

-- find mean value for  HourSpendOnApp column */ 
set @mean_HourSpendOnApp= (select round(avg(HourSpendOnApp)) from  customer_churn);
-- Impute mean values
update customer_churn 
set HourSpendOnApp = @mean_HourSpendOnApp
where HourSpendOnApp is Null;
select * from customer_churn where HourSpendOnApp is Null ;

-- find mean value for OrderAmountHikeFromlastYear column */
set @mean_OrderAmountHikeFromlastYear= (select round(avg(OrderAmountHikeFromlastYear)) from  customer_churn);
-- Impute mean values
update customer_churn 
set OrderAmountHikeFromlastYear = @mean_OrderAmountHikeFromlastYear
where OrderAmountHikeFromlastYear is Null;
select * from customer_churn where OrderAmountHikeFromlastYear is Null ;

 -- find mean value for DaySinceLastOrder column 
 set @mean_DaySinceLastOrder= (select round(avg(DaySinceLastOrder)) from  customer_churn);
-- Impute mean values
update customer_churn 
set DaySinceLastOrder = @mean_DaySinceLastOrder
where DaySinceLastOrder is Null;
select * from customer_churn where DaySinceLastOrder is Null ;

-- ➢ Impute mode for the following columns: Tenure, CouponUsed, OrderCount.
select * from customer_churn where tenure is null;
set @mode_tenure=(select (count(*)) count from customer_churn where tenure is not null group by tenure order by count desc limit 1);
update customer_churn
set tenure = @mode_tenure
where tenure is null;

-- find mode value for CouponUsed column 
select * from customer_churn where CouponUsed is null;
set @mode_CouponUsed=(select (count(*)) count from customer_churn where CouponUsed is not null group by CouponUsed order by count desc limit 1);

-- Impute mode
update customer_churn
set CouponUsed = @mode_CouponUsed
where CouponUsed is null;

-- find mode value for OrderCount column 
select * from customer_churn where OrderCount is null;
set @mode_OrderCount=(select (count(*)) count from customer_churn where OrderCount is not null group by OrderCount order by count desc limit 1);

-- Impute mode
update customer_churn
set OrderCount = @mode_OrderCount
where OrderCount is null;

-- ➢ Handle outliers in the 'WarehouseToHome' column by deleting rows where the
-- values are greater than 100.
select * from customer_churn where warehousetohome > 100;
delete from customer_churn where warehousetohome > 100;
/*===================================================================================*/

-- Dealing with Inconsistencies --
-- Replace occurrences of "Mobile” in the 'PreferedOrderCat' column with “Mobile Phone” to ensure uniformity
select * from customer_churn where PreferedOrderCat = 'Mobile';
update customer_churn
set PreferedOrderCat = if(PreferedOrderCat='Mobile','Mobile Phone',PreferedOrderCat) ;
/*===================================================================================*/

-- Standardize payment mode values: Replace "COD" with "Cash on Delivery" and  "CC" with "Credit Card" in the PreferredPaymentMode column --

select * from customer_churn where  PreferredPaymentMode in ('cc','cod') ;
update customer_churn
set PreferredPaymentMode = case
							when PreferredPaymentMode =  'cc' then 'Credit Card' 
							when PreferredPaymentMode = 'cod' then 'Cash On Delivery'
							else PreferredPaymentMode
						  end ;
			
            -- Data Transformation --
-- Column Renaming --
-- ➢ Rename the column "PreferedOrderCat" to "PreferredOrderCat".            
alter table customer_churn
 Rename column PreferedOrderCat to PreferredOrderCat;
-- ➢ Rename the column "HourSpendOnApp" to "HoursSpentOnApp".
alter table customer_churn
Rename column HourSpendOnApp to HoursSpentOnApp;
 
 -- Creating New Columns --
 
 -- ➢ Create a new column named ‘ComplaintReceived’ with values "Yes" if the
-- corresponding value in the ‘Complain’ is 1, and "No" otherwise.
 alter table  customer_churn
 add column ComplaintReceived enum('Yes','No'),
 add column ChurnStatus enum('Churned','Active');
 
 select * from customer_churn;

-- ➢ Create a new column named 'ChurnStatus'. Set its value to “Churned” if the
-- corresponding value in the 'Churn' column is 1, else assign “Active”.
update customer_churn
 set ComplaintReceived = if(complain = 1,'Yes','No'),
  ChurnStatus = if(churn = 1,'Churned','Active');
  
  select * from customer_churn;
  /*===================================================================================*/

-- Column Dropping -- 
-- ➢ Drop the columns "Churn" and "Complain" from the table.
 alter table customer_churn
 drop column Churn,
 drop column Complain;
-- Enable sql safe update --
set sql_safe_updates = 1;
 /*===================================================================================*/
 select * from customer_churn;
 
    -- Data Exploration and Analysis --
    
-- 1. Retrieve the count of churned and active customers from the dataset --
select * from customer_churn;
select ChurnStatus , count(*) as Count_Of_Customer from customer_churn group by churnstatus order by ChurnStatus desc ;

-- 2.  Display the average tenure of customers who churned.
select Round(avg(tenure),2) Average_Tenure from  customer_churn where ChurnStatus = 'Churned' ;

--  3. Calculate the total cashback amount earned by customers who churned 
 select ChurnStatus,concat('$  ' ,sum(CashbackAmount)) as Total_CashBack from customer_churn where ChurnStatus = 'Churned';
 
--  4. Determine the percentage of churned customers who complained 
 select churnstatus as Customer, concat(round((count(churnStatus)/(select count(churnstatus) from customer_churn) * 100),2) ,'  % ')as percentage, complaintReceived from customer_churn where churnstatus = 'Churned' group by ComplaintReceived having ComplaintReceived = 'Yes' ;
 
 -- 5. Find the gender distribution of customers who complained. 
 select Gender ,count( complaintReceived ) as Complaint_Received from  customer_churn  where complaintReceived ='yes' group by Gender  ;

--  6. Identify the city tier with the highest number of churned customers whose  preferred order category is Laptop & Accessory. 
select CityTier,count(ChurnStatus) as churned_Customer from customer_churn where PreferredOrderCat = 'Laptop & Accessory' group by CityTier order by churned_Customer desc limit 1;

-- 7. Identify the most preferred payment mode among active customers.*/
select PreferredPaymentMode as Most_Preferred_Payment_mode, count(PreferredPaymentMode) as Payment_Mode_count from customer_churn where ChurnStatus = 'Active'  group by PreferredPaymentMode order by Payment_Mode_count desc limit 1;

--  8. List the preferred login device(s) among customers who took more than 10 days  since their last order*/
SELECT PreferredLoginDevice, COUNT(*) AS DeviceCount FROM customer_churn WHERE DaySinceLastOrder > 10 GROUP BY PreferredLoginDevice ORDER BY DeviceCount DESC limit 1 ;

--   9. List the number of active customers who spent more than 3 hours on the app.*/
 select  count(*) as NO_OF_ACTIVE_CUSTOMER, concat( HoursSpentOnApp , " Hours")  as HoursSpentOnApp  from customer_churn where ChurnStatus = 'Active' and HoursSpentOnApp > 3 group by HoursSpentOnApp ;

--  10. Find the average cashback amount received by customers who spent at least 2 hours on the app.*/
select concat('$  ', round(avg(CashbackAmount),2)) as AverageCashbackAmount  from customer_churn where HoursSpentOnApp >= 2;

-- 11. Display the maximum hours spent on the app by customers in each preferred  order category */
Select PreferredOrderCat as PreferredOrderCategory ,concat( max(HoursSpentOnApp), ' Hours') as Maximum_hours_spent from customer_churn group by PreferredOrderCat order by PreferredOrderCategory ;

--  12. Find the average order amount hike from last year for customers in each marital  status category*/
select MaritalStatus, concat('$  ',Round(avg(OrderAmountHikeFromlastYear),2)) as AverageOrderAmountHike  from customer_churn group by MaritalStatus order by MaritalStatus desc ;

-- 13. Calculate the total order amount hike from last year for customers who are single  and prefer mobile phones for ordering. */
select sum(OrderAmountHikeFromlastYear) as TotalOrderAmountHikeFromLastYear from customer_churn where MaritalStatus = 'Single' and PreferredOrderCat = 'Mobile Phone';

--   14. Find the average number of devices registered among customers who used UPI as their preferred payment mode.*/
select round(avg(NumberOfDeviceRegistered)) as AverageNumberOfDevices from customer_churn where PreferredPaymentMode='UPI';

--  15. Determine the city tier with the highest number of customers.*/
select CityTier, count( * ) as No_of_Customer   from customer_churn group by CityTier order by No_of_Customer desc limit 1 ; 

--  16. Find the marital status of customers with the highest number of addresses.*/
select MaritalStatus,Max(NumberOfAddress) as HighestNumberOfAddress from customer_churn group by MaritalStatus order by HighestNumberOfAddress desc limit 1;

--  17. Identify the gender that utilized the highest number of coupons. */
select gender, sum(CouponUsed) as NumberOfCouponsUsed from customer_churn group by gender order by NumberOfCouponsUsed desc limit 1;

-- 18. List the average satisfaction score in each of the preferred order categories. */
select PreferredOrderCat as Preferred_Order_Categories ,round(avg(SatisfactionScore),2) as Average_Satisfaction_Score from customer_churn group by PreferredOrderCat order by Average_Satisfaction_Score ;

-- 19. Calculate the total order count for customers who prefer using credit cards and  have the maximum satisfaction score.*/
select PreferredPaymentMode, sum(OrderCount) AS Total_OrderCount   from customer_churn where PreferredPaymentMode ='Credit Card' and SatisfactionScore = (select max(SatisfactionScore) from customer_churn) group by PreferredPaymentMode ;

-- 20. How many customers are there who spent only one hour on the app and days  since their last order was more than 5? */
select count(*) as Number_of_customer from customer_churn where HoursSpentOnApp = 1 and DaySinceLastOrder > 5 ;

--  21. What is the average satisfaction score of customers who have complained? */
select round(avg(SatisfactionScore),2) as Average_SatisfactionScore from customer_churn where ComplaintReceived = 'Yes';

--  22. How many customers are there in each preferred order category? */
Select PreferredOrderCat Preferred_Order_Category,count(*) as No_Of_Customer  from customer_churn group by preferredOrderCat order by No_OF_Customer desc;

-- 23. What is the average cashback amount received by married customers? */
select concat('$  ',round(avg(CashbackAmount),2)) as Average_Cashback_Amount from customer_churn where MaritalStatus = 'Married' ;

-- 24. What is the average number of devices registered by customers who are not  using Mobile Phone as their preferred login device?*/
select Round(avg(NumberOfDeviceRegistered)) as Average_No_Of_Devices from customer_churn where PreferredLoginDevice not in ('Mobile Phone');

--  25. List the preferred order category among customers who used more than 5  coupons.*/
select PreferredOrderCat , count(*) as Category_count from customer_churn where CouponUsed > 5 group by PreferredOrderCat order by Category_count desc   ;

-- 26. List the top 3 preferred order categories with the highest average cashback  amount.*/
select PreferredOrderCat , concat('$  ',round(avg(CashbackAmount),2)) as Highest_CashBack_Amount from customer_churn  group by PreferredOrderCat order by Highest_CashBack_Amount desc limit 3;

-- 27. Find the preferred payment modes of customers whose average tenure is 10 months and have placed more than 500 orders.*/
select PreferredPaymentMode ,COUNT(*) AS PaymentModeCount  from customer_churn WHERE Tenure = 10 AND OrderCount > 500 GROUP BY PreferredPaymentMode ORDER BY PaymentModeCount DESC;

-- 28. Categorize customers based on their distance from the warehouse to home such
 -- as 'Very Close Distance' for distances <=5km, 'Close Distance' for <=10km,
 -- 'Moderate Distance' for <=15km, and 'Far Distance' for >15km. Then, display the
-- churn status breakdown for each distance category
select case 
		when WarehouseToHome <= 5 then 'Very Close Distance'
        when WarehouseToHome <=10 then 'Close Distance'
        when  WarehouseToHome <=15 then 'Moderate Distance' 
        else 'Far Distance'
        end  as DistanceCategory,
        ChurnStatus ,
        count(*) as CustomerCount
 from customer_churn  GROUP BY DistanceCategory, ChurnStatus ORDER BY DistanceCategory, ChurnStatus;

-- 29. List the customer’s order details who are married, live in City Tier-1, and their
-- order counts are more than the average number of orders placed by all
 -- customers --
select * from customer_churn where CityTier='1' and OrderCount > (select avg(OrderCount) from customer_churn) and MaritalStatus = 'Married';

 --  30. a) Create a ‘customer_returns’ table in the ‘ecomm’ database and insert the
 -- following data --
 
CREATE TABLE Customer_Returns(
  ReturnID INT,
  CustomerID INT,
  ReturnDate DATE,
  RefundAmount DECIMAL(10, 2)
);

--  insert values into customer_return table --
INSERT INTO Customer_Returns (ReturnID, CustomerID, ReturnDate, RefundAmount) VALUES
(1001, 50022, '2023-01-01', 2130),
(1002, 50316, '2023-01-23', 2000),
(1003, 51099, '2023-02-14', 2290),
(1004, 52321, '2023-03-08', 2510),
(1005, 52928, '2023-03-20', 3000),
(1006, 53749, '2023-04-17', 1740),
(1007, 54206, '2023-04-21', 3250),
(1008, 54838, '2023-04-30', 1990);
select * from Customer_Returns;

--  30.  b) Display the return details along with the customer details of those who have
 -- churned and have made complaints --
 select * from customer_churn;
select CR.* , CC.* from Customer_Returns CR
join Customer_churn CC  on CR.customerId =  CC.customerId 
where CC.ChurnStatus = 'Churned' and CC.ComplaintReceived='Yes' ;





