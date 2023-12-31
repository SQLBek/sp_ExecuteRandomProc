/****** Object:  StoredProcedure [dbo].[sp_ExecuteRandomProc]    Script Date: 10/21/2023 3:40:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_ExecuteRandomProc] (
	@NumToExec INT = 1,
	@SchemaName SYSNAME = 'workload',
	@PrintOnly BIT = 0
)
AS
/*-----------------------------------------------------------------------------
-- dbo.sp_ExecuteRandomProc
--
-- Written By: Andy Yun
-- Created On: 2021-10-19
-- 
-- Summary
-- This procedure was created as a randomized workload utility, primarily for
-- demo purposes.  
--
--
-- Usage
--
-- Example 1: Execute 1 random procedure from the 'workload' schema
-- EXEC dbo.sp_ExecuteRandomProc
--
-- Example 2: Execute 3 random procedures from the 'dbo' schema
-- EXEC dbo.sp_ExecuteRandomProc @NumToExec 3, @SchemaName = 'dbo'
--
-- Example 3: Print commands for 5 random procedures from the 'dbo' schema
-- EXEC dbo.sp_ExecuteRandomProc @NumToExec 5, @SchemaName = 'dbo', @PrintOnly = 1
--
-----------------------------------------------------------------------------*/
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;
	DECLARE 
		@SQLCmd NVARCHAR(4000),
		@ProcID INT,
		@MaxProcID INT,
		@ModValue3 INT,
		@ProcLoopCounter INT = 1;

	CREATE TABLE #tmpWorkloadProcs (
		ProcID INT IDENTITY(1, 1) PRIMARY KEY CLUSTERED,
		SQLCmd NVARCHAR(4000)
	);

	INSERT INTO #tmpWorkloadProcs (SQLCmd)
	SELECT 
		'EXEC ' + schemas.name + '.' + objects.name + ';'
	FROM sys.objects
	INNER JOIN sys.schemas
		ON objects.schema_id = schemas.schema_id
	WHERE objects.type = 'P'
		AND schemas.name = @SchemaName;

	SELECT @MaxProcID = MAX(ProcID)
	FROM #tmpWorkloadProcs;
	
	WITH CTE_A (x) AS (
		SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 
	),
	CTE_B (x) AS (
		SELECT 1
		FROM CTE_A t1 CROSS APPLY CTE_A t2
	)
	-- Returns up to 10,000
	SELECT 
		TOP 10000
		ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS X
	INTO #tmpCount
	FROM CTE_B t1 
	CROSS APPLY CTE_B t2;

	PRINT '-----------------------------------';
	PRINT 'Starting Random Proc Workload';

	DECLARE rsRandomProc CURSOR FAST_FORWARD FOR 
		SELECT X
		FROM #tmpCount
		WHERE X <= @NumToExec
		ORDER BY X;

	OPEN rsRandomProc;

	FETCH NEXT 
		FROM rsRandomProc INTO @ProcLoopCounter;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		-- Do Stuff
		PRINT '';
		PRINT '---------------------';
		PRINT 'ProcLoopCounter = ' + CAST(@ProcLoopCounter AS VARCHAR(10));

		-- Execute a random workload stored procedure
		SELECT @SQLCmd = SQLCmd
		FROM #tmpWorkloadProcs
		WHERE ProcID = (CAST((RAND() * 10000) AS INT) % @MaxProcID) + 1;

		PRINT 'SQLCmd:';
		PRINT @SQLCmd;
		PRINT '';
		PRINT '***';
		PRINT '';

		IF @PrintOnly = 0
		BEGIN
			EXEC sp_executesql @SQLCmd;
		END

		PRINT '';
		PRINT '***';
		PRINT '';

		FETCH NEXT 
 			FROM rsRandomProc INTO @ProcLoopCounter;
		END  
	CLOSE rsRandomProc;
	DEALLOCATE rsRandomProc;

	
END

