/* Requires Ola's Mainteance scripts
        https://ola.hallengren.com/
*/
EXECUTE [dbo].[IndexOptimize]
    @Databases = 'USER_DATABASES' ,
    @FragmentationLow = NULL ,
    @FragmentationMedium = NULL ,
    @FragmentationHigh = NULL ,
    @UpdateStatistics = 'ALL' ,
    @OnlyModifiedStatistics = N'Y' ,
    @LogToTable = N'N'