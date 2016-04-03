Configuration geppy_xChromeBrowser {
  Param(
    [Parameter(ParameterSetName = 'LocalInstaller',
               Mandatory = $True)]
    [String]$InstallerPath,
    
    [Parameter(ParameterSetName = 'RemoteInstaller')]
    [String]$Language = "en",
    
    [Parameter(ParameterSetName = 'RemoteInstaller')]
    [Boolean]$SetAsDefaultBrowser = $False,
    
    [Parameter(ParameterSetName = 'RemoteInstaller')]
    [Boolean]$SubmitUsageStatistics = $False,
    
    [Parameter(ParameterSetName = 'RemoteInstaller')]
    [Boolean]$MatchSource = $True
  );
  Import-DscResource -ModuleName 'PSDesiredStateConfiguration';
  Import-DscResource -ModuleName 'xPSDesiredStateConfiguration';
  
  if($InstallerPath -ne '') {
    # Don't redownload the installer
    $MatchSource = $False;
  } else {
    $InstallerPath = "${env:tmp}/geppy_xChromeBrowser.exe";
    
    $Parameters = @{
      browser = 4;
      lang = $Language;
      usagestats = if($SubmitUsageStatistics) { 1 } else { 0 };
      appname = 'Google%2520Chrome';
      needsadmin = 'prefers';
    };
    
    if($SetAsDefaultBrowser) {
      $Parameters += @{
        installdataindex = 'defaultbrowser';
      };
    }
    
    # We need a URL-encoded query string to use as part of the path
    $EncodedParameters = [String]::Join(
      '%26',
      @($Parameters.Keys | foreach {
        "${_}%3D" + $Parameters[$_];
        }
      )
    );
  }
  
  xRemoteFile Downloader {
    Uri = "https://dl.google.com/tag/s/appguid%3D%7B8A69D345-D564-463C-AFF1-A69D9E530F96%7D%26iid%3D%7BEDACD302-E2B2-5C2A-3569-F13F32D91CA8%7D%26${EncodedParameters}/update2/installers/ChromeStandaloneSetup.exe";
    DestinationPath = $InstallerPath;
    MatchSource = $MatchSource;
  }
  
  Package Installer {
    Name = 'Google Chrome';
    Path = $InstallerPath;
    ProductId = '';
    Arguments = '/silent /install';
    DependsOn = '[xRemoteFile]Downloader';
  }
}
