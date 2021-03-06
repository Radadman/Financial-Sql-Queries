
--Select checks with a certain item
Select distinct concat(ch.LocationID, convert(int,ch.DOB,0), ch.CheckNumber) AS CheckID, SUM(ch.GrossPrice) AS GrossPrice
FROM (Select it.* FROM ItemDetail it WHERE it.LocationID = 22 AND it.DOB BETWEEN @StartDate and @EndDate) ch 
WHERE exists (Select e1.LocationID, e1.DOB, e1.CheckNumber FROM (Select id.* FROM ItemDetail id WHERE id.ItemID = 201 and id.DOB BETWEEN @StartDate and @EndDate and LocationID = 22) e1 WHERE concat(e1.LocationID, convert(int,e1.DOB,0), e1.CheckNumber) = concat(ch.LocationID, convert(int,ch.DOB,0), ch.CheckNumber))
GROUP BY ch.LocationID, ch.DOB, ch.CheckNumber
ORDER BY CheckID

--Select checks with kids meals
Select distinct concat(ch.LocationID, convert(int,ch.DOB,0), ch.CheckNumber) AS CheckID, SUM(ch.GrossPrice) AS GrossPrice
FROM (Select it.* FROM ItemDetail it WHERE it.LocationID = 22 AND it.DOB BETWEEN @StartDate and @EndDate) ch 
WHERE exists (Select e1.LocationID, e1.DOB, e1.CheckNumber FROM (Select id.* FROM ItemDetail id WHERE id.ItemID IN (1376,1669,1767,1358,1687,1766,9258,1666,1308,2085,189,188,186,187,12507,1384,1857,1410,1853,1331,1619,1942,8334,8336,12498,8342,8346)
and id.DOB BETWEEN @StartDate and @EndDate and LocationID = 22) e1 WHERE concat(e1.LocationID, convert(int,e1.DOB,0), e1.CheckNumber) = concat(ch.LocationID, convert(int,ch.DOB,0), ch.CheckNumber))
GROUP BY ch.LocationID, ch.DOB, ch.CheckNumber
ORDER BY CheckID

--Select only checks that have sandwich (no catering)
SELECT distinct concat(exp.LocationID, convert(int,exp.DOB,0), exp.CheckNumber) AS CheckID, SUM(exp.GrossPrice) AS GrossPrice, SUM(exp.NetPrice) AS NetPrice
FROM (Select id.* FROM ItemDetail id INNER JOIN ItemGroupMember igm ON id.ItemID = igm.ItemID Where DOB Between @StartDate and @EndDate and igm.ItemGroupID = 281) exp
WHERE 
DOB BETWEEN @StartDate and @EndDate
AND GrossPrice > 4.5
GROUP BY exp.LocationID, exp.DOB, exp.CheckNumber

--Select only checks that have a catering item
SELECT concat(exp.LocationID, convert(int,exp.DOB,0), exp.CheckNumber) AS CheckID, exp.GrossPrice, exp.NetPrice, exp.MasterSaleDepartmentID
FROM 
(SELECT id.LocationID, id.DOB, id.CheckNumber, id.GrossPrice, id.NetPrice, msd.MasterSaleDepartmentID 
FROM ItemDetail id
INNER JOIN Item it ON id.ItemID = it.ItemID
INNER JOIN SaleDepartment sd ON it.SaleDepartmentID = sd.SaleDepartmentID
INNER JOIN MasterSaleDepartment msd ON sd.MasterSaleDepartmentID = msd.MasterSaleDepartmentID 
WHERE DOB BETWEEN @StartDate and @EndDate) exp
WHERE exists 
(SELECT cat.LocationID, cat.DOB, cat.CheckNumber, cat.ItemID, cat.GrossPrice, cat.NetPrice, cat.MasterSaleDepartmentID
FROM (SELECT id.*, sd.MasterSaleDepartmentID FROM ItemDetail id
INNER JOIN Item it ON id.ItemID = it.ItemID 
INNER JOIN SaleDepartment sd ON it.SaleDepartmentID = sd.SaleDepartmentID and sd.MasterSaleDepartmentID = 3
WHERE DOB BETWEEN @StartDate and @EndDate) cat WHERE concat(cat.LocationID,convert(int,cat.DOB,0), cat.CheckNumber) = concat(exp.LocationID, convert(int,exp.DOB,0), exp.CheckNumber))

--Count # of catering checks
SELECT count(distinct(concat(id.LocationID, convert(int,id.DOB,0), id.CheckNumber))) AS CheckID
FROM ItemDetail id
INNER JOIN Item it ON id.ItemID = it.ItemID
INNER JOIN SaleDepartment sd ON it.SaleDepartmentID = sd.SaleDepartmentID
INNER JOIN MasterSaleDepartment msd ON sd.MasterSaleDepartmentID = msd.MasterSaleDepartmentID 
WHERE id.DOB BETWEEN '@StartDate' and '@EndDate' 
and msd.MasterSaleDepartmentID = 3

-- Count of catering checks by location by day
SELECT exp.LocationID, convert(varchar(10), exp.DOB, 110) AS Date, count(distinct concat(exp.LocationID, convert(int,exp.DOB,0), exp.CheckNumber)) AS CheckCount
FROM 
(SELECT id.LocationID, lgm.LocationGroupID, id.DOB, id.CheckNumber, id.GrossPrice, id.NetPrice, msd.MasterSaleDepartmentID  
FROM ItemDetail id
INNER JOIN Item it ON id.ItemID = it.ItemID
INNER JOIN SaleDepartment sd ON it.SaleDepartmentID = sd.SaleDepartmentID
INNER JOIN MasterSaleDepartment msd ON sd.MasterSaleDepartmentID = msd.MasterSaleDepartmentID
INNER JOIN LocationGroupMember lgm ON id.LocationID = lgm.LocationID
WHERE DOB BETWEEN '@StartDate' and '@EndDate') exp
WHERE exists 
(SELECT cat.LocationID, cat.DOB, cat.CheckNumber, cat.ItemID, cat.GrossPrice, cat.NetPrice, cat.MasterSaleDepartmentID
FROM (SELECT id.*, sd.MasterSaleDepartmentID FROM ItemDetail id
INNER JOIN Item it ON id.ItemID = it.ItemID 
INNER JOIN SaleDepartment sd ON it.SaleDepartmentID = sd.SaleDepartmentID and sd.MasterSaleDepartmentID = 3
WHERE DOB BETWEEN '@StartDate' and '@EndDate') cat WHERE concat(cat.LocationID,convert(int,cat.DOB,0), cat.CheckNumber) = concat(exp.LocationID, convert(int,exp.DOB,0), exp.CheckNumber))
AND exp.LocationGroupID = 1782
GROUP BY exp.LocationID, exp.DOB

-- Count Items where check has a combo
Select sum(exp.Quantity)
From (Select id.*, igm.ItemGroupID From ItemDetail id INNER JOIN ItemGroupMember igm ON id.ItemID = igm.ItemID WHERE id.DOB BETWEEN '@StartDate' AND '@EndDate') exp
    Where
    exists (Select e1.ItemGroupID From (Select id.*, igm.ItemGroupID From ItemGroupMember igm INNER JOIN ItemDetail id ON igm.ItemID = id.ItemID WHERE id.DOB BETWEEN '@StartDate' AND '@EndDate' AND igm.ItemGroupID in (302) AND id.GrossPrice >1) e1 Where concat(e1.LocationID, convert(int,e1.DOB,0), e1.CheckNumber) = concat(exp.LocationID, convert(int,exp.DOB,0), exp.CheckNumber))
and exists (Select e1.ItemGroupID From (Select id.*, igm.ItemGroupID From ItemGroupMember igm INNER JOIN ItemDetail id ON igm.ItemID = id.ItemID WHERE id.DOB BETWEEN '@StartDate' AND '@EndDate' AND igm.ItemGroupID in (303) AND id.GrossPrice >1) e1 Where concat(e1.LocationID, convert(int,e1.DOB,0), e1.CheckNumber) = concat(exp.LocationID, convert(int,exp.DOB,0), exp.CheckNumber))
and exists (Select e1.ItemGroupID From (Select id.*, igm.ItemGroupID From ItemGroupMember igm INNER JOIN ItemDetail id ON igm.ItemID = id.ItemID WHERE id.DOB BETWEEN '@StartDate' AND '@EndDate' AND igm.ItemGroupID in (178,179,180) AND id.GrossPrice >1) e1 Where concat(e1.LocationID, convert(int,e1.DOB,0), e1.CheckNumber) = concat(exp.LocationID, convert(int,exp.DOB,0), exp.CheckNumber))
AND exp.ItemGroupID IN (178,179,180)
AND exp.GrossPrice >1

-- Count Items for Item Group and Location Group
SELECT sum(exp.Quantity)
From (Select id.quantity, id.GrossPrice, id.LocationID, id.DOB, id.CheckNumber, id.ItemID, igm.ItemGroupID From ItemDetail id INNER JOIN ItemGroupMember igm ON id.ItemID = igm.ItemID WHERE id.DOB BETWEEN '@StartDate' AND '@EndDate') exp
    Where
    exists (Select e1.ItemGroupID From (Select id.quantity, id.GrossPrice, id.LocationID, id.DOB, id.CheckNumber, id.ItemID, igm.ItemGroupID From ItemGroupMember igm INNER JOIN ItemDetail id ON igm.ItemID = id.ItemID WHERE id.DOB BETWEEN '@StartDate' AND '@EndDate' AND igm.ItemGroupID = 302 AND id.GrossPrice >1) e1 Where concat(e1.LocationID, convert(int,e1.DOB,0), e1.CheckNumber) = concat(exp.LocationID, convert(int,exp.DOB,0), exp.CheckNumber))
and exists (Select e1.ItemGroupID From (Select id.quantity, id.GrossPrice, id.LocationID, id.DOB, id.CheckNumber, id.ItemID, igm.ItemGroupID From ItemGroupMember igm INNER JOIN ItemDetail id ON igm.ItemID = id.ItemID WHERE id.DOB BETWEEN '@StartDate' AND '@EndDate' AND igm.ItemGroupID = 303 AND id.GrossPrice >1) e1 Where concat(e1.LocationID, convert(int,e1.DOB,0), e1.CheckNumber) = concat(exp.LocationID, convert(int,exp.DOB,0), exp.CheckNumber))
and exists (Select e1.ItemGroupID From (Select id.quantity, id.GrossPrice, id.LocationID, id.DOB, id.CheckNumber, id.ItemID, igm.ItemGroupID From ItemGroupMember igm INNER JOIN ItemDetail id ON igm.ItemID = id.ItemID WHERE id.DOB BETWEEN '@StartDate' AND '@EndDate' AND igm.ItemGroupID in (178,179,180) AND id.GrossPrice >1) e1 Where concat(e1.LocationID, convert(int,e1.DOB,0), e1.CheckNumber) = concat(exp.LocationID, convert(int,exp.DOB,0), exp.CheckNumber))
AND exp.ItemGroupID = 303
AND exp.GrossPrice >1

-- Count Checks and Sum Net Price for all Catering Checks
SELECT exp.LocationID, exp.LocationName, convert(varchar(10), exp.DOB, 110) AS Date, count(distinct concat(exp.LocationID, convert(int,exp.DOB,0), exp.CheckNumber)) AS CheckCount, sum(exp.NetPrice) as NetSales
FROM 
(SELECT id.LocationID, lo.LocationName,  lgm.LocationGroupID, id.DOB, id.CheckNumber, id.GrossPrice, id.NetPrice, msd.MasterSaleDepartmentID  
FROM ItemDetail id
INNER JOIN Item it ON id.ItemID = it.ItemID
INNER JOIN SaleDepartment sd ON it.SaleDepartmentID = sd.SaleDepartmentID
INNER JOIN MasterSaleDepartment msd ON sd.MasterSaleDepartmentID = msd.MasterSaleDepartmentID
INNER JOIN LocationGroupMember lgm ON id.LocationID = lgm.LocationID
INNER JOIN Location lo ON id.LocationID = lo.LocationID
WHERE DOB BETWEEN '@StartDate' and '@EndDate') exp
WHERE exists 
(SELECT cat.LocationID, cat.DOB, cat.CheckNumber, cat.ItemID, cat.GrossPrice, cat.NetPrice, cat.MasterSaleDepartmentID
FROM (SELECT id.*, sd.MasterSaleDepartmentID FROM ItemDetail id
INNER JOIN Item it ON id.ItemID = it.ItemID 
INNER JOIN SaleDepartment sd ON it.SaleDepartmentID = sd.SaleDepartmentID and sd.MasterSaleDepartmentID = 3
WHERE DOB BETWEEN '@StartDate' and '@EndDate' and id.GrossPrice > 1) cat WHERE concat(cat.LocationID,convert(int,cat.DOB,0), cat.CheckNumber) = concat(exp.LocationID, convert(int,exp.DOB,0), exp.CheckNumber))
AND exp.LocationGroupID = 1
GROUP BY exp.LocationID, exp.LocationName, exp.DOB

-- Bread Use
SELECT id.LocationID, ig.ItemGroupName, min(convert(varchar(10),id.DOB,110)) as StartDate, max(convert(varchar(10),id.DOB,110)) as EndDate,SUM(id.Quantity) as Sandwiches, 
CASE When igm.ItemGroupID = 127 Then Round(((SUM(id.Quantity) * 7)/21),2) 
When igm.ItemGroupID = 128 Then Round(((Sum(id.Quantity)*10.5)/21),2)
When igm.ItemGroupID = 129 Then Round(((Sum(id.Quantity)*14)/21),2)
When igm.ItemGroupID = 261 Then Round(((Sum(id.Quantity)*3.5)/21),2)
When igm.ItemGroupID = 314 Then Round(((Sum(id.Quantity)*5)/21),2)
When igm.ItemGroupID = 130 Then Round(((Sum(id.Quantity)*10*7)/21),2)
When igm.ItemGroupID = 282 Then Round(((Sum(id.Quantity)*15*7)/21),2)
When igm.ItemGroupID = 131 Then Round(((Sum(id.Quantity)*6*7)/21),2)
Else Round(((Sum(id.Quantity)*23)/21),2)
END as Loaves,
CASE When igm.ItemGroupID = 127 Then Round((((SUM(id.Quantity) * 7)/21)/24),2) 
When igm.ItemGroupID = 128 Then Round((((Sum(id.Quantity)*10.5)/21)/24),2)
When igm.ItemGroupID = 129 Then Round((((Sum(id.Quantity)*14)/21)/24),2)
When igm.ItemGroupID = 261 Then Round((((Sum(id.Quantity)*3.5)/21)/24),2)
When igm.ItemGroupID = 314 Then Round((((Sum(id.Quantity)*5)/21)/24),2)
When igm.ItemGroupID = 130 Then Round((((Sum(id.Quantity)*10*7)/21)/24),2)
When igm.ItemGroupID = 282 Then Round((((Sum(id.Quantity)*15*7)/21)/24),2)
When igm.ItemGroupID = 131 Then Round((((Sum(id.Quantity)*6*7)/21)/24),2)
Else Round((((Sum(id.Quantity)*23)/21)/24),2)
END as Cases
FROM ItemDayTotal id
INNER JOIN ItemGroupMember igm ON id.ItemID = igm.ItemID
INNER JOIN ItemGroup ig ON igm.ItemGroupID = ig.ItemGroupID
INNER JOIN LocationGroupMember lgm ON id.LocationID = lgm.LocationID 
WHERE id.DOB Between '@StartDate' and '@EndDate'
AND igm.ItemGroupID IN (127, 128, 129, 261, 314, 130, 282, 131, 246)
AND lgm.LocationGroupID = '@LocationGroupID'
GROUP BY id.LocationID, ig.ItemGroupName, igm.ItemGroupID

-- Catering Orders by location by day by check
SELECT exp.LocationID, exp.LocationName, convert(varchar(10), exp.DOB, 110) AS Date, count(distinct concat(exp.LocationID, convert(int,exp.DOB,0), exp.CheckNumber)) AS CheckCount, sum(exp.GrossPrice) as GrossSales, sum(exp.NetPrice) as NetSales
FROM 
(SELECT id.LocationID, lo.LocationName,  lgm.LocationGroupID, id.DOB, id.CheckNumber, id.GrossPrice, id.NetPrice, msd.MasterSaleDepartmentID  
FROM ItemDetail id
INNER JOIN Item it ON id.ItemID = it.ItemID
INNER JOIN SaleDepartment sd ON it.SaleDepartmentID = sd.SaleDepartmentID
INNER JOIN MasterSaleDepartment msd ON sd.MasterSaleDepartmentID = msd.MasterSaleDepartmentID
INNER JOIN LocationGroupMember lgm ON id.LocationID = lgm.LocationID
INNER JOIN Location lo ON id.LocationID = lo.LocationID
WHERE DOB BETWEEN '@StartDate' and '@EndDate') exp
WHERE exists 
(SELECT cat.LocationID, cat.DOB, cat.CheckNumber, cat.ItemID, cat.GrossPrice, cat.NetPrice, cat.MasterSaleDepartmentID
FROM (SELECT id.*, sd.MasterSaleDepartmentID FROM ItemDetail id
INNER JOIN Item it ON id.ItemID = it.ItemID 
INNER JOIN SaleDepartment sd ON it.SaleDepartmentID = sd.SaleDepartmentID and sd.MasterSaleDepartmentID = 3
WHERE DOB BETWEEN '@StartDate' and '@EndDate' and id.GrossPrice > 1) cat WHERE concat(cat.LocationID,convert(int,cat.DOB,0), cat.CheckNumber) = concat(exp.LocationID, convert(int,exp.DOB,0), exp.CheckNumber))
AND exp.LocationGroupID = 1 -- Comp Group 1733
GROUP BY exp.LocationID, exp.LocationName, exp.DOB, exp.CheckNumber
ORDER BY NetSales asc

-- Net Sales of Promo/Comp
SELECT exp.LocationID, exp.LocationName, convert(varchar(10), exp.DOB, 110) AS Date, count(distinct concat(exp.LocationID, convert(int,exp.DOB,0), exp.CheckNumber)) AS CheckCount, sum(exp.NetPrice) as NetSales, sum(exp.GrossPrice) as GrossSales
FROM 
(SELECT id.LocationID, lo.LocationName,  lgm.LocationGroupID, id.DOB, id.CheckNumber, id.GrossPrice, id.NetPrice
FROM ItemDetail id
INNER JOIN LocationGroupMember lgm ON id.LocationID = lgm.LocationID
INNER JOIN Location lo ON id.LocationID = lo.LocationID
WHERE DOB BETWEEN '@StartDate' and '@EndDate') exp
WHERE exists 
(SELECT cat.LocationID, cat.DOB, cat.CheckNumber, cat.ItemID, cat.CompID
FROM (SELECT cd.* FROM CompDetail cd 
WHERE cd.DOB BETWEEN '@StartDate' and '@EndDate' and cd.CompID = 306) cat WHERE concat(cat.LocationID,convert(int,cat.DOB,0), cat.CheckNumber) = concat(exp.LocationID, convert(int,exp.DOB,0), exp.CheckNumber))
AND exp.LocationGroupID = 1
GROUP BY exp.LocationID, exp.LocationName, exp.DOB

-- Number of guests (sandwiches) for radio test
Select sum(idt.Quantity)
FROM ItemDayTotal idt
INNER JOIN ItemGroupMember igm ON idt.ItemID = igm.ItemID and igm.ItemGroupID = 165
WHERE idt.DOB BETWEEN '@StartDate' and '@EndDate'
AND LocationID IN (212,204,126,90,64,13,439,370,369,274,429,428,426,392,391,256,165,80,436,269,441,170,147,86,443,347,279,271,257,228,188,184,116,513,333,215,95,55)  
AND idt.GrossPrice <> 0


-- Catering Item Quantity by Day by Location
SELECT idt.LocationID, convert(varchar(10), idt.DOB, 110), sum(idt.Quantity) as Quantity, sum(idt.NetPrice) as NetSales
FROM ItemDayTotal idt
INNER JOIN Item it ON idt.ItemID = it.ItemID
INNER JOIN SaleDepartment sd ON it.SaleDepartmentID = sd.SaleDepartmentID and sd.MasterSaleDepartmentID = 3
INNER JOIN LocationGroupMember lgm ON idt.LocationID = lgm.LocationID
WHERE lgm.LocationGroupID = 1
AND idt.DOB BETWEEN '@StartDate' and '@EndDate'
AND idt.GrossPrice > 1
GROUP BY idt.LocationID, idt.DOB
ORDER BY idt.LocationID
