# dbo.sp_ExecuteRandomProc

**Written By:** Andy Yun
**Created On:** 2021-10-19
 ---
## Summary
This procedure was created as a randomized workload utility, primarily for
demo purposes.  

---
## Examples

1. Execute 1 random procedure from the 'workload' schema  
`EXEC dbo.sp_ExecuteRandomProc`

3. Execute 3 random procedures from the 'dbo' schema  
`EXEC dbo.sp_ExecuteRandomProc @NumToExec 3, @SchemaName = 'dbo'`

4. Print commands for 5 random procedures from the 'dbo' schema  
`EXEC dbo.sp_ExecuteRandomProc @NumToExec 5, @SchemaName = 'dbo', @PrintOnly = 1`
