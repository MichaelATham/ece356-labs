# Part (b) in manual
SELECT t AS total_instances, n AS inducted, t - n AS notInducted, n / t AS inducted_proportion, (t - n) / t AS notInducted_proportion
FROM 
    (SELECT COUNT(DISTINCT playerID) AS t FROM HallOfFame) AS A, 
    (SELECT COUNT(DISTINCT playerID) AS n FROM HallOfFame 
     WHERE REPLACE(REPLACE(Inducted, '\r', ''), '\n', '') = 'Y') AS h;
       
       
WITH
AllStarStats AS (
    SELECT playerID, SUM(GP) AS TotalGP
    FROM AllStarFull
    GROUP BY playerID
),

TeamStats AS (
	SELECT a.playerID, 
			SUM(CASE WHEN REPLACE(REPLACE(t.WSWin, '\r', ''), '\n', '') = 'Y' THEN 1 ELSE 0 END) as WSWins,
			CASE 
				WHEN (SUM(t.W) + SUM(t.L)) > 0 THEN SUM(t.W) / (SUM(t.W) + SUM(t.L))  -- Win Percentage
				ELSE 0  -- Avoid division by zero if no games are recorded
			END AS WinPercent
	FROM Appearances a JOIN Teams t ON a.teamID = t.teamID AND a.yearID = t.yearID
	GROUP BY a.playerID 
),

BattingStats AS (
    SELECT
        playerID,
        ROUND(COALESCE(SUM(H), 0), 2) AS H,
        ROUND(COALESCE(SUM(HR), 0), 2) AS HR,
        ROUND(COALESCE(SUM(RBI), 0), 2) AS RBI,
        ROUND(COALESCE(SUM(R), 0), 2) AS R,
        ROUND(COALESCE(SUM(`2B`), 0), 2) AS Doubles,
        ROUND(COALESCE(SUM(`3B`), 0), 2) AS Triples,
        ROUND(COALESCE(SUM(BB), 0), 2) AS BB,
        ROUND(COALESCE(SUM(AB), 0), 2) AS AB
    FROM Batting
    GROUP BY playerID
),

FieldingStats AS (
    SELECT
        playerID,
        ROUND(COALESCE(SUM(PO), 0), 2) AS PO,
        ROUND(COALESCE(SUM(A), 0), 2) AS A,
        ROUND(COALESCE(SUM(E), 0), 2) AS E,
        ROUND(COALESCE(SUM(DP), 0), 2) AS DP,
        ROUND(COALESCE(SUM(SB), 0), 2) AS SB,
        ROUND(COALESCE(SUM(CS), 0), 2) AS CS
    FROM Fielding
    GROUP BY playerID
),

PitchingStats AS (
    SELECT
        playerID,
        ROUND(COALESCE(SUM(ERA), 0), 2) AS ERA,
        ROUND(COALESCE(SUM(H), 0), 2) AS H_pi,
        ROUND(COALESCE(SUM(SV), 0), 2) AS SV,
        ROUND(COALESCE(SUM(BAOpp), 0), 2) AS BAOpp
    FROM Pitching
    GROUP BY playerID
),

BattingPostStats AS (
    SELECT
        playerID,
        ROUND(COALESCE(SUM(H), 0), 2) AS H,
        ROUND(COALESCE(SUM(HR), 0), 2) AS HR,
        ROUND(COALESCE(SUM(RBI), 0), 2) AS RBI,
        ROUND(COALESCE(SUM(R), 0), 2) AS R,
        ROUND(COALESCE(SUM(`2B`), 0), 2) AS Doubles,
        ROUND(COALESCE(SUM(`3B`), 0), 2) AS Triples,
        ROUND(COALESCE(SUM(BB), 0), 2) AS BB,
        ROUND(COALESCE(SUM(AB), 0), 2) AS AB
    FROM BattingPost
    GROUP BY playerID
),

FieldingPostStats AS (
    SELECT
        playerID,
        ROUND(COALESCE(SUM(PO), 0), 2) AS PO,
        ROUND(COALESCE(SUM(A), 0), 2) AS A,
        ROUND(COALESCE(SUM(E), 0), 2) AS E,
        ROUND(COALESCE(SUM(DP), 0), 2) AS DP,
        ROUND(COALESCE(SUM(SB), 0), 2) AS SB,
        ROUND(COALESCE(SUM(CS), 0), 2) AS CS
    FROM Fielding
    GROUP BY playerID
),

PitchingPostStats AS (
    SELECT
        playerID,
        ROUND(COALESCE(SUM(ERA), 0), 2) AS ERA,
        ROUND(COALESCE(SUM(H), 0), 2) AS H_pi,
        ROUND(COALESCE(SUM(SV), 0), 2) AS SV,
        ROUND(COALESCE(SUM(BAOpp), 0), 2) AS BAOpp
    FROM Pitching
    GROUP BY playerID
),

AwardStats AS (
    SELECT playerID, 
    SUM(CASE WHEN REPLACE(REPLACE(awardID, '\r', ''), '\n', '') IN ('Most Valuable Player', 'Cy Young Award', 'Gold Glove', 'Silver Slugger') THEN 1 ELSE 0 END) AS careerAwards
    FROM AwardsPlayers
    GROUP BY playerID
),

HallOfFameClass AS (
    SELECT playerID, 
           CASE 
               WHEN MAX(CASE WHEN REPLACE(REPLACE(inducted, '\r', ''), '\n', '') = 'Y' THEN 1 ELSE 0 END) = 1 THEN 1 
               ELSE 0 
           END AS class
    FROM HallOfFame
    GROUP BY playerID
)

SELECT
    fp.playerID,
    COALESCE(ts.WinPercent, 0) AS WinPercent,
    
    COALESCE(b.H, 0) AS H_Batting,
    COALESCE(b.HR, 0) AS HR_Batting,
    COALESCE(b.RBI, 0) AS RBI_Batting,
    COALESCE(b.R, 0) AS R_Batting,
    COALESCE(b.Doubles, 0) AS Doubles_Batting,
    COALESCE(b.Triples, 0) AS Triples_Batting,
    COALESCE(b.BB, 0) AS BB_Batting,
    COALESCE(b.AB, 0) AS AB_Batting,
    COALESCE(f.PO, 0) AS PO_Fielding,
    COALESCE(f.A, 0) AS A_Fielding,
    COALESCE(f.E, 0) AS E_Fielding,
    COALESCE(f.DP, 0) AS DP_Fielding,
    COALESCE(f.SB, 0) AS SB_Fielding,
    COALESCE(f.CS, 0) AS CS_Fielding,
    COALESCE(pi.ERA, 0) AS ERA_Pitching,
    COALESCE(pi.H_pi, 0) AS H_Pitching,
    COALESCE(pi.SV, 0) AS SV_Pitching,
    COALESCE(pi.BAOpp, 0) AS BAOpp_Pitching,
--     
    COALESCE(bp.H, 0) AS H_Battingp,
    COALESCE(bp.HR, 0) AS HR_Battingp,
    COALESCE(bp.RBI, 0) AS RBI_Battingp,
    COALESCE(bp.R, 0) AS R_Battingp,
    COALESCE(bp.Doubles, 0) AS Doubles_Battingp,
    COALESCE(bp.Triples, 0) AS Triples_Battingp,
    COALESCE(bp.BB, 0) AS BB_Battingp,
    COALESCE(bp.AB, 0) AS AB_Battingp,
    COALESCE(fip.PO, 0) AS PO_Fieldingp,
    COALESCE(fip.A, 0) AS A_Fieldingp,
    COALESCE(fip.E, 0) AS E_Fieldingp,
    COALESCE(fip.DP, 0) AS DP_Fieldingp,
    COALESCE(fip.SB, 0) AS SB_Fieldingp,
    COALESCE(fip.CS, 0) AS CS_Fieldingp,
    COALESCE(pip.ERA, 0) AS ERA_Pitchingp,
    COALESCE(pip.H_pi, 0) AS H_Pitchingp,
    COALESCE(pip.SV, 0) AS SV_Pitchingp,
    COALESCE(pip.BAOpp, 0) AS BAOpp_Pitchingp,
    
    COALESCE(asa.TotalGP, 0) AS GP_AllStar,
    COALESCE(aw.careerAwards, 0) AS careerAwards,
    COALESCE(ts.WSWins, 0) AS WSWins,
    hc.class
    
FROM People fp
LEFT JOIN BattingStats b ON fp.playerID = b.playerID
LEFT JOIN FieldingStats f ON fp.playerID = f.playerID
LEFT JOIN PitchingStats pi ON fp.playerID = pi.playerID
LEFT JOIN BattingPostStats bp ON fp.playerID = bp.playerID
LEFT JOIN FieldingPostStats fip ON fp.playerID = fip.playerID
LEFT JOIN PitchingPostStats pip ON fp.playerID = pip.playerID
LEFT JOIN AllStarStats asa ON fp.playerID = asa.playerID
LEFT JOIN AwardStats aw ON fp.playerID = aw.playerID
LEFT JOIN TeamStats ts ON fp.playerID = ts.playerID
LEFT JOIN HallOfFameClass hc ON fp.playerID = hc.playerID
WHERE hc.playerID IS NOT NULL;
