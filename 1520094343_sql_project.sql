/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */
SELECT name FROM Facilities WHERE membercost != 0

/* Q2: How many facilities do not charge a fee to members? */
SELECT COUNT(name) FROM Facilities WHERE membercost = 0

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
SELECT facid, name, membercost, monthlymaintenance FROM Facilities WHERE membercost < 0.20 * monthlymaintenance AND membercost != 0

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */
SELECT * FROM Facilities WHERE facid IN (1,5)

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */
SELECT name,
       monthlymaintenance,
       CASE WHEN monthlymaintenance > 100 THEN 'expensive'
            ELSE 'cheap' END AS cheap_expensive
  FROM Facilities

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */
SELECT firstname, surname, joindate FROM Members
WHERE joindate = (SELECT MAX(joindate) FROM Members)

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
SELECT DISTINCT CONCAT(M.firstname, ' ', M.surname, ' ', F.name) AS 'Member - Tennis Court'
  FROM Bookings B
  JOIN Members M ON B.memid = M.memid
  JOIN Facilities F ON F.facid = B.facid
  WHERE F.facid IN (0,1) 
  ORDER BY M.firstname

/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */
SELECT CONCAT(name, ' ', firstname, ' ', surname) AS 'Facility_Member Name', 
       CASE WHEN B.memid != 0 THEN F.membercost * B.slots  
       ELSE F.guestcost * B.slots  END AS Cost
        
       FROM Bookings B
	   JOIN Members M
       ON B.memid = M.memid
       JOIN Facilities F
	   ON B.facid = F.facid


       WHERE B.starttime LIKE '2012-09-14%'
       AND ((M.memid = 0 AND F.guestcost * B.slots > 30) OR
            (M.memid != 0 AND F.membercost * B.slots > 30))

       ORDER BY Cost DESC

/* Q9: This time, produce the same result as in Q8, but using a subquery. */
SELECT Facility_and_Member_Name, Cost FROM
(

SELECT CONCAT(name, ' ', firstname, ' ', surname) AS Facility_and_Member_Name,

       CASE WHEN B.memid != 0 THEN F.membercost * B.slots  
       ELSE F.guestcost * B.slots  END AS Cost
        
       FROM Bookings AS B
	   JOIN Members AS M
       ON B.memid = M.memid
       JOIN Facilities AS F
	   ON B.facid = F.facid


       WHERE B.starttime LIKE '2012-09-14%'
  )  AS Try
WHERE
       Cost > 30
       ORDER BY Cost DESC

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
SELECT name, Revenue FROM
(
SELECT F.name, SUM(slots * case
			WHEN memid = 0 then F.guestcost
			ELSE F.membercost
		END) as Revenue
	FROM Bookings B
	INNER JOIN Facilities F
		ON B.facid = F.facid
    
    GROUP BY F.name
    ORDER BY Revenue
) AS Trial
WHERE Revenue < 1000
