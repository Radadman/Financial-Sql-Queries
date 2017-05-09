--Select only checks that have sandwich and drink
Select distinct concat(exp.LocationID, convert(int,exp.DOB,0), exp.CheckNumber) AS CheckID, SUM(exp.GrossPrice) AS GrossPrice, SUM(exp.NetPrice) AS NetPrice
    From (Select id.* From ItemGroupMember igm INNER JOIN ItemDetail id ON igm.ItemID = id.ItemID WHERE id.DOB BETWEEN @StartDate AND @EndDate AND id.LocationID = 22) exp
    Where
    exists (Select e1.ItemGroupID From (Select id.*, igm.ItemGroupID From ItemGroupMember igm INNER JOIN ItemDetail id ON igm.ItemID = id.ItemID WHERE id.DOB BETWEEN @StartDate AND @EndDate AND id.LocationID = 22 AND igm.ItemGroupID in (281)) e1 Where concat(e1.LocationID, convert(int,e1.DOB,0), e1.CheckNumber) = concat(exp.LocationID, convert(int,exp.DOB,0), exp.CheckNumber))
    and exists (Select e1.ItemGroupID From (Select id.*, igm.ItemGroupID From ItemGroupMember igm INNER JOIN ItemDetail id ON igm.ItemID = id.ItemID WHERE id.DOB BETWEEN @StartDate AND @EndDate AND id.LocationID = 22 and igm.ItemGroupID in (274)) e1 Where concat(e1.LocationID, convert(int,e1.DOB,0), e1.CheckNumber) = concat(exp.LocationID, convert(int,exp.DOB,0), exp.CheckNumber))
    and not exists (Select e1.ItemGroupID From (Select id.*, igm.ItemGroupID From ItemGroupMember igm INNER JOIN ItemDetail id ON igm.ItemID = id.ItemID WHERE id.DOB BETWEEN @StartDate AND @EndDate AND id.LocationID = 22 and igm.ItemGroupID in (280, 34)) e1 Where concat(e1.LocationID, convert(int,e1.DOB,0), e1.CheckNumber) = concat(exp.LocationID, convert(int,exp.DOB,0), exp.CheckNumber))
GROUP BY exp.LocationID, exp.DOB, exp.CheckNumber
ORDER BY CheckID

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
