param([Parameter(Mandatory=$true)][long]$WindowId,
      [ValidateSet('maximize', 'fullscreen')][string]$Action)
$ErrorActionPreference = 'Stop'
Add-Type @'
using System;
using System.Runtime.InteropServices;
public static class PlanetVimWindow {
    [StructLayout(LayoutKind.Sequential)] public struct RECT { public int Left, Top, Right, Bottom; }
    [StructLayout(LayoutKind.Sequential)] public struct MONITORINFO { public int Size; public RECT Monitor, Work; public uint Flags; }
    [DllImport("user32.dll")] public static extern bool IsWindow(IntPtr window);
    [DllImport("user32.dll")] public static extern bool IsZoomed(IntPtr window);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr window, int command);
    [DllImport("user32.dll")] public static extern int GetWindowLong(IntPtr window, int index);
    [DllImport("user32.dll")] public static extern int SetWindowLong(IntPtr window, int index, int value);
    [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr window, out RECT rect);
    [DllImport("user32.dll")] public static extern IntPtr MonitorFromWindow(IntPtr window, uint flags);
    [DllImport("user32.dll")] public static extern bool GetMonitorInfo(IntPtr monitor, ref MONITORINFO info);
    [DllImport("user32.dll")] public static extern bool SetWindowPos(IntPtr window, IntPtr after, int x, int y, int width, int height, uint flags);
    [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern bool SetProp(IntPtr window, string name, IntPtr value);
    [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern IntPtr GetProp(IntPtr window, string name);
    [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern IntPtr RemoveProp(IntPtr window, string name);
}
'@
$window = [IntPtr]$WindowId
if (-not [PlanetVimWindow]::IsWindow($window)) { throw 'The GVim window no longer exists.' }
if ($Action -eq 'maximize') {
    $command = if ([PlanetVimWindow]::IsZoomed($window)) { 9 } else { 3 }
    [void][PlanetVimWindow]::ShowWindow($window, $command)
    exit
}
$prefix = 'PlanetVimFullscreen'
$savedStyle = [PlanetVimWindow]::GetProp($window, $prefix + 'Style').ToInt64()
if ($savedStyle -ne 0) {
    $bounds = @('Left', 'Top', 'Width', 'Height') | ForEach-Object {
        [PlanetVimWindow]::RemoveProp($window, $prefix + $_).ToInt32()
    }
    [void][PlanetVimWindow]::RemoveProp($window, $prefix + 'Style')
    [void][PlanetVimWindow]::SetWindowLong($window, -16, [int]$savedStyle)
    [void][PlanetVimWindow]::SetWindowPos($window, [IntPtr]::Zero, $bounds[0], $bounds[1], $bounds[2], $bounds[3], 0x64)
} else {
    $style = [PlanetVimWindow]::GetWindowLong($window, -16)
    $rect = New-Object PlanetVimWindow+RECT
    [void][PlanetVimWindow]::GetWindowRect($window, [ref]$rect)
    $bounds = @{Left=$rect.Left; Top=$rect.Top; Width=($rect.Right-$rect.Left); Height=($rect.Bottom-$rect.Top)}
    foreach ($key in $bounds.Keys) { [void][PlanetVimWindow]::SetProp($window, $prefix + $key, [IntPtr]$bounds[$key]) }
    [void][PlanetVimWindow]::SetProp($window, $prefix + 'Style', [IntPtr]$style)
    $info = New-Object PlanetVimWindow+MONITORINFO
    $info.Size = [Runtime.InteropServices.Marshal]::SizeOf($info)
    [void][PlanetVimWindow]::GetMonitorInfo([PlanetVimWindow]::MonitorFromWindow($window, 2), [ref]$info)
    $screen = $info.Monitor
    [void][PlanetVimWindow]::SetWindowLong($window, -16, ($style -band (-bnot 0x00CF0000)))
    [void][PlanetVimWindow]::SetWindowPos($window, [IntPtr]::Zero, $screen.Left, $screen.Top, ($screen.Right-$screen.Left), ($screen.Bottom-$screen.Top), 0x64)
}
