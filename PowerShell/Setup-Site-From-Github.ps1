# TODO make this a function / module with real params 

# Options

$repo = "Carfinance.Touch"
$port = 6612


$isDotNetCore = $true # TODO use Global.asax to detect dotnet core 


$githubPath = "E:\MotorMart";
$releasesPath = "E:\MotorMart\_releases"
$nugetPath = "E:\tools\";
$msbuildPath = "C:/Program Files (x86)/MSBuild/14.0/bin";



# The magic

$env:Path += ";$nugetPath;$msbuildPath"

cd $githubPath

Clone-Or-Update $repo

if ($isDotNetCore -eq $true) {
    dotnet restore
    dotnet build

    echo "Creating IIS site"
    Start-IISCommitDelay
    
    $apiDir = "$releasesPath\${repo}";

    $iisSite = New-IISSite -Name $repo -PhysicalPath $apiDir -Force -BindingInformation "*:${port}:localhost" -Passthru
	$iisSite.Applications["/"].ApplicationPoolName = "asp core"

	Stop-IISCommitDelay
    echo "Created IIS site"
} else {
    nuget restore
    msbuild /v:quiet

    echo "Creating IIS site"
    Start-IISCommitDelay

    $iisSite = New-IISSite -Name $repo -PhysicalPath "$githubPath\$repo\${repo}.api\" -Force -BindingInformation "*:${port}:localhost" -Passthru
	$iisSite.Applications["/"].ApplicationPoolName = "cf247"

	Stop-IISCommitDelay
    echo "Created IIS site"
}

echo $url
echo "pinging site..."
$url = "http://localhost:$port" 
Invoke-WebRequest -Uri $url -usebasicParsing | Select StatusCode, Content

function Clone-Or-Update($repo) {
    if (Test-Path $repo){
        cd $repo
        git pull
    } else {
        echo "cloning $repo"
        git clone -q "https://github.com/Carfinance247/${repo}.git"
        cd $repo
    }
}
