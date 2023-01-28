Configuration ooTemp {
    Import-DscResource -ModuleName FileSystemDsc -ModuleVersion 1.1.1

    #region Add a C:\Temp
    File 'CreateTempDirectory' {
        DestinationPath = 'C:\Temp'
        Ensure          = 'Present'
        Type            = 'Directory'
    }

    FileSystemAccessRule 'GrantAccessToTempDirectory' {
        Path      = 'C:\Temp'
        Identity  = 'EVERYONE'
        Rights    = @('FullControl')
        DependsOn = '[File]CreateTempDirectory'
    }
    #endregion
}
