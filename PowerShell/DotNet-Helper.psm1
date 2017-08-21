
function dotnetpublish($service) {
	$folder = getrepo #current folder
	$releasesFolder = "E:\MotorMart\_Releases";
	
	$service = if ($service -eq $null) { $folder } else { $service }
	write-warning "Publishing $service"
	
	#stop the exe
	write-warning "Checking if process is running"
	$running = get-process -processname "${service}.Api" -ErrorAction SilentlyContinue
	if ($running) {
		write-warning "Attempting to stop process"
		Stop-Process -processname "${service}.Api"
	}
	
	write-warning "Calling dotnet publish"
	#publish to the _releases folder
	#msbuild Carfinance.ContactCentre.Api.xproj /p:target=Publish /p:DeployOnBuild=true /p:PublishDir="$releasesFolder\Test\" /p:Configuration=Debug /p:Platform="Any CPU" # asp core RC
	dotnet publish "src\${service}.Api" -o $releasesFolder\$service
	
	# Set the secrets
	$jwtSecret = "" # TODO
	$clientSecret = "" # TODO
	
	& "E:\work\PowerShell\Replace-JsonValue.ps1" "$releasesFolder\$service\appsettings.json" -key:"JwtSecret" -value:$jwtSecret
	& "E:\work\PowerShell\Replace-JsonValue.ps1" "$releasesFolder\$service\appsettings.json" -key:"ClientSecret" -value:$clientSecret
	
	$appsettings = "$releasesFolder\$service\appsettings.json"
	$appsettingsdev = "$releasesFolder\$service\appsettings.development.json"
  
        # Fix the incorrect connection strings - some projects are setup WRONG
	if ($appsettings | Test-Path) { (Get-Content $appsettings) | ForEach-Object {$_ -replace "=MotorMart;", "=MotorMartLocal;"} | Set-Content $appsettings }
	if ($appsettingsdev | Test-Path) { 
		(Get-Content $appsettingsdev) | ForEach-Object {$_ -replace "=MotorMart;", "=MotorMartLocal;"} | Set-Content $appsettingsdev 
		& "E:\work\PowerShell\Replace-JsonValue.ps1" "$releasesFolder\$service\appsettings.development.json" -key:"JwtSecret" -value:$jwtSecret
		& "E:\work\PowerShell\Replace-JsonValue.ps1" "$releasesFolder\$service\appsettings.development.json" -key:"ClientSecret" -value:$clientSecret
	}
	if ($service -eq "Carfinance.Application.Info") { (Get-Content "$releasesFolder\$service\${service}.api.exe.config") | ForEach-Object {$_ -replace "{connection-string}", "Data Source=localhost;Initial Catalog=MotorMartLocal;Integrated Security=True;"} | Set-Content "$releasesFolder\$service\${service}.Api.exe.config" }
	
	#Ping the Api to wake it up
	$bindings = Get-IISSite $service | Select Bindings
	$hostname = if($bindings.Bindings.bindingInformation.split(":")[2] -eq "" ){"localhost"} else {$bindings.Bindings.bindingInformation.split(":")[2]};
	$url = $bindings.Bindings.protocol + "://" + $hostname + ":" + $bindings.Bindings.bindingInformation.split(":")[1]
	write-host "Pinging $url"
	Invoke-WebRequest -Uri $url -usebasicParsing | Select StatusCode
}

function getrepo () {
	$repodir = git rev-parse --show-toplevel
	$repo = Split-Path $repodir -Leaf
	return $repo;
}

Export-ModuleMember -function dotnetpublish -Alias dotnet-publish
