Configuration ooTemp {
    #region Add a C:\Temp
    File 'CreateTempDirectory' {
        DestinationPath = 'C:\Temp'
        Ensure = 'Present'
        Type = 'Directory'
    }

    xFileSystemAccessRule 'GrantAccessToTempDirectory' {
        Path = 'C:\Temp'
        Identity = 'EVERYONE'
        Rights = @('FullControl')
        DependsOn = '[File]CreateTempDirectory'
    }
    #endregion
}

