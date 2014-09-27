function Load-Packages
{
    param ([string] $directory = 'Packages')
    $assemblies = Get-ChildItem $directory -Recurse -Filter '*.dll' | Select -Expand FullName
    foreach ($assembly in $assemblies) { [System.Reflection.Assembly]::LoadFrom($assembly) }
}

Load-Packages

$routes = @{
    "/ola" = { return '<html><body>Hello world!</body></html>' }
    "/json" = { return '[{hello: "world"},{hello: "world"}]' }
}

$url = 'http://localhost:8080/'
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($url)
$listener.Start()

Write-Host "Listening at $url..."

while ($listener.IsListening)
{
    
    #maybe put a detect ctrl-c event here: http://books.google.com/books?id=fJROwhJlZaYC&pg=PA457&lpg=PA457&dq=powershell+while+loop+ctrl-c&source=bl&ots=HfHwp3ZnEO&sig=anyx4qQJg5ORgwpWiPE_FaG6yXA&hl=en&sa=X&ei=gUAnVO-iCoS3yASxnIHABQ&ved=0CDIQ6AEwAw#v=onepage&q=powershell%20while%20loop%20ctrl-c&f=false

    $context = $listener.GetContext()
    $requestUrl = $context.Request.Url
    $response = $context.Response

    Write-Host ''
    Write-Host "> $requestUrl"

    $localPath = $requestUrl.LocalPath
    $route = $routes.Get_Item($requestUrl.LocalPath)

    if ($route -eq $null)
    {
        $response.StatusCode = 404
    }
    else
    {
        $content = & $route
        $buffer = [System.Text.Encoding]::UTF8.GetBytes($content)
        $response.ContentLength64 = $buffer.Length
        $response.OutputStream.Write($buffer, 0, $buffer.Length)
    }
    
    $response.Close()

    $responseStatus = $response.StatusCode
    Write-Host "< $responseStatus"
}