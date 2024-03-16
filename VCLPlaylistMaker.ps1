param(
    [Parameter(Mandatory, Position=0)]
    [String] $InputPath,
    [Parameter(Mandatory, Position=1)]
    [String] $Filter,
    [Parameter(Mandatory, Position=2)]
    [String] $OutputFile
)

$files = Get-ChildItem -Path $InputPath -Filter $Filter -Recurse | ForEach-Object { $_.FullName }

$xmlSettings = New-Object System.Xml.XmlWriterSettings
$xmlSettings.Indent = $true
$xmlSettings.IndentChars = "`t"
$xmlSettings.NewLineChars = "`n"

$outputPath = Join-Path $InputPath $OutputFile
$xmlWriter = [System.Xml.XmlWriter]::Create($outputPath, $xmlSettings)

$xmlWriter.WriteStartDocument()
$xmlWriter.WriteStartElement("playlist", "http://xspf.org/ns/0/")
    $xmlWriter.WriteAttributeString("xmlns", "vlc", $null, "http://www.videolan.org/vlc/playlist/ns/0/")
    $xmlWriter.WriteAttributeString("version", "1")
    $xmlWriter.WriteStartElement("trackList")

    for ($i = 0; $i -lt $files.Length; $i++)
    {
        $xmlWriter.WriteStartElement("track")
        $xmlWriter.WriteElementString("location", "file:///$($files[$i].Replace("\", "/"))")
            $xmlWriter.WriteStartElement("extension")
            $xmlWriter.WriteAttributeString("application", "http://www.videolan.org/vlc/playlist/0")
            $xmlWriter.WriteElementString("vlc", "id", "http://www.videolan.org/vlc/playlist/ns/0/", $i)
            $xmlWriter.WriteEndElement()
        $xmlWriter.WriteEndElement()
    }

$xmlWriter.WriteEndElement()

$xmlWriter.WriteStartElement("extension")
$xmlWriter.WriteAttributeString("application", "http://www.videolan.org/vlc/playlist/0")

for ($i = 0; $i -lt $files.Length; $i++)
{
    $xmlWriter.WriteStartElement("vlc", "item", "http://www.videolan.org/vlc/playlist/ns/0/")
    $xmlWriter.WriteAttributeString("tid", $i)
    $xmlWriter.WriteEndElement()
}

$xmlwriter.WriteEndElement()
$xmlWriter.WriteEndDocument()
$xmlWriter.Flush()
$xmlWriter.Close()