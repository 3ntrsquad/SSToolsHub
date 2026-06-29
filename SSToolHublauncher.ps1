# ==============================================================================
# SSToolsHub Launcher - SIMPLE v14.0
# ==============================================================================
# NO COMPLEX ROUNDING - Just clean, working design
# ==============================================================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Runtime.InteropServices

# ==============================================================================
# WIN32 - For rounding the main form only
# ==============================================================================
if (-not ([System.Management.Automation.PSTypeName]'Win32').Type) {
    Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
    [DllImport("user32.dll")]
    public static extern int SetWindowRgn(IntPtr hWnd, IntPtr hRgn, bool bRedraw);
    [DllImport("gdi32.dll")]
    public static extern IntPtr CreateRoundRectRgn(int x1, int y1, int x2, int y2, int cx, int cy);
    [DllImport("user32.dll")]
    public static extern int ReleaseCapture();
    [DllImport("user32.dll")]
    public static extern int SendMessage(IntPtr hWnd, int Msg, int wParam, int lParam);
}
"@
}

function Make-Rounded {
    param($control, $radius = 20)
    try {
        $rgn = [Win32]::CreateRoundRectRgn(0, 0, $control.Width, $control.Height, $radius, $radius)
        [Win32]::SetWindowRgn($control.Handle, $rgn, $true)
    } catch {}
}

# ==============================================================================
# COLORS
# ==============================================================================
$bgColor = [System.Drawing.Color]::FromArgb(15, 15, 30)
$cardColor = [System.Drawing.Color]::FromArgb(25, 22, 45)
$cardLight = [System.Drawing.Color]::FromArgb(35, 30, 55)
$primary = [System.Drawing.Color]::FromArgb(124, 58, 237)
$primaryLight = [System.Drawing.Color]::FromArgb(139, 92, 246)
$accent = [System.Drawing.Color]::FromArgb(6, 182, 212)
$text = [System.Drawing.Color]::FromArgb(230, 230, 240)
$textSec = [System.Drawing.Color]::FromArgb(170, 170, 200)
$textMuted = [System.Drawing.Color]::FromArgb(100, 100, 130)
$white = [System.Drawing.Color]::White

# ==============================================================================
# FORM
# ==============================================================================
$form = New-Object System.Windows.Forms.Form
$form.Text = "SSToolsHub Launcher"
$form.Size = New-Object System.Drawing.Size(600, 620)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "None"
$form.BackColor = $bgColor
$form.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$form.TopMost = $true

$form.Add_Shown({
    Make-Rounded -control $form -radius 25
})

# ==============================================================================
# TITLE BAR
# ==============================================================================
$titleBar = New-Object System.Windows.Forms.Panel
$titleBar.Size = New-Object System.Drawing.Size(600, 50)
$titleBar.Location = New-Object System.Drawing.Point(0, 0)
$titleBar.BackColor = $cardColor
$form.Controls.Add($titleBar)

$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = "🚀 SSToolsHub Launcher"
$titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
$titleLabel.ForeColor = $text
$titleLabel.Size = New-Object System.Drawing.Size(500, 50)
$titleLabel.Location = New-Object System.Drawing.Point(15, 0)
$titleLabel.TextAlign = "MiddleLeft"
$titleBar.Controls.Add($titleLabel)

$closeBtn = New-Object System.Windows.Forms.Button
$closeBtn.Text = "✕"
$closeBtn.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$closeBtn.Size = New-Object System.Drawing.Size(35, 35)
$closeBtn.Location = New-Object System.Drawing.Point(555, 8)
$closeBtn.FlatStyle = "Flat"
$closeBtn.FlatAppearance.BorderSize = 0
$closeBtn.BackColor = [System.Drawing.Color]::Transparent
$closeBtn.ForeColor = $textMuted
$closeBtn.Cursor = [System.Windows.Forms.Cursors]::Hand
$closeBtn.Add_Click({ $form.Close() })
$closeBtn.Add_MouseEnter({ $closeBtn.ForeColor = [System.Drawing.Color]::FromArgb(248, 113, 113) })
$closeBtn.Add_MouseLeave({ $closeBtn.ForeColor = $textMuted })
$titleBar.Controls.Add($closeBtn)

$titleBar.Add_MouseDown({
    if ($_.Button -eq [System.Windows.Forms.MouseButtons]::Left) {
        [Win32]::ReleaseCapture()
        [Win32]::SendMessage($form.Handle, 0xA1, 0x2, 0)
    }
})

# ==============================================================================
# CONTENT
# ==============================================================================
$mainPanel = New-Object System.Windows.Forms.Panel
$mainPanel.Size = New-Object System.Drawing.Size(580, 550)
$mainPanel.Location = New-Object System.Drawing.Point(10, 55)
$mainPanel.BackColor = [System.Drawing.Color]::Transparent
$mainPanel.AutoScroll = $true
$form.Controls.Add($mainPanel)

# ==============================================================================
# WELCOME
# ==============================================================================
$welcomeCard = New-Object System.Windows.Forms.Panel
$welcomeCard.Size = New-Object System.Drawing.Size(540, 70)
$welcomeCard.Location = New-Object System.Drawing.Point(20, 10)
$welcomeCard.BackColor = $cardLight
$mainPanel.Controls.Add($welcomeCard)

$welcomeText = New-Object System.Windows.Forms.Label
$welcomeText.Text = "✨ Welcome to SSToolsHub"
$welcomeText.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
$welcomeText.ForeColor = $white
$welcomeText.Size = New-Object System.Drawing.Size(520, 30)
$welcomeText.Location = New-Object System.Drawing.Point(15, 5)
$welcomeCard.Controls.Add($welcomeText)

$welcomeSub = New-Object System.Windows.Forms.Label
$welcomeSub.Text = "Premium Tool Hub • Powered by 3NTR"
$welcomeSub.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$welcomeSub.ForeColor = $textSec
$welcomeSub.Size = New-Object System.Drawing.Size(520, 25)
$welcomeSub.Location = New-Object System.Drawing.Point(15, 40)
$welcomeCard.Controls.Add($welcomeSub)

# ==============================================================================
# TOOL INFO
# ==============================================================================
$toolCard = New-Object System.Windows.Forms.Panel
$toolCard.Size = New-Object System.Drawing.Size(540, 110)
$toolCard.Location = New-Object System.Drawing.Point(20, 90)
$toolCard.BackColor = $cardColor
$mainPanel.Controls.Add($toolCard)

$toolTitle = New-Object System.Windows.Forms.Label
$toolTitle.Text = "📌 TOOL INFORMATION"
$toolTitle.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$toolTitle.ForeColor = $accent
$toolTitle.Size = New-Object System.Drawing.Size(520, 25)
$toolTitle.Location = New-Object System.Drawing.Point(15, 5)
$toolCard.Controls.Add($toolTitle)

$toolInfo = @(
    "🔧 These tools are NOT created by me",
    "📚 All tools belong to their respective authors",
    "⚖️ Provided for educational and forensic purposes only"
)

$yOffset = 35
foreach ($info in $toolInfo) {
    $label = New-Object System.Windows.Forms.Label
    $label.Text = $info
    $label.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $label.ForeColor = $textSec
    $label.Size = New-Object System.Drawing.Size(520, 22)
    $label.Location = New-Object System.Drawing.Point(15, $yOffset)
    $toolCard.Controls.Add($label)
    $yOffset += 25
}

# ==============================================================================
# CREDITS
# ==============================================================================
$creditsCard = New-Object System.Windows.Forms.Panel
$creditsCard.Size = New-Object System.Drawing.Size(540, 190)
$creditsCard.Location = New-Object System.Drawing.Point(20, 210)
$creditsCard.BackColor = $cardColor
$mainPanel.Controls.Add($creditsCard)

$creditsTitle = New-Object System.Windows.Forms.Label
$creditsTitle.Text = "👤 MY INFORMATION"
$creditsTitle.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$creditsTitle.ForeColor = $primaryLight
$creditsTitle.Size = New-Object System.Drawing.Size(520, 25)
$creditsTitle.Location = New-Object System.Drawing.Point(15, 5)
$creditsCard.Controls.Add($creditsTitle)

$creditsInfo = @(
    @{ Icon = "💬"; Label = "Discord"; Value = "@unseentracking"; Color = [System.Drawing.Color]::FromArgb(88, 101, 242) },
    @{ Icon = "⛏️"; Label = "Minecraft"; Value = "3ntrsquad"; Color = [System.Drawing.Color]::FromArgb(74, 222, 128) },
    @{ Icon = "🎯"; Label = "Bio"; Value = "SSER in OrbitalFFA"; Color = [System.Drawing.Color]::FromArgb(251, 191, 36) }
)

$yOffset2 = 35
foreach ($item in $creditsInfo) {
    $iconLbl = New-Object System.Windows.Forms.Label
    $iconLbl.Text = $item.Icon
    $iconLbl.Font = New-Object System.Drawing.Font("Segoe UI", 14)
    $iconLbl.Size = New-Object System.Drawing.Size(35, 30)
    $iconLbl.Location = New-Object System.Drawing.Point(15, $yOffset2)
    $creditsCard.Controls.Add($iconLbl)
    
    $labelLbl = New-Object System.Windows.Forms.Label
    $labelLbl.Text = "$($item.Label):"
    $labelLbl.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $labelLbl.ForeColor = $text
    $labelLbl.Size = New-Object System.Drawing.Size(90, 30)
    $labelLbl.Location = New-Object System.Drawing.Point(55, $yOffset2)
    $creditsCard.Controls.Add($labelLbl)
    
    $valueLbl = New-Object System.Windows.Forms.Label
    $valueLbl.Text = $item.Value
    $valueLbl.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $valueLbl.ForeColor = $item.Color
    $valueLbl.Size = New-Object System.Drawing.Size(380, 30)
    $valueLbl.Location = New-Object System.Drawing.Point(150, $yOffset2)
    $creditsCard.Controls.Add($valueLbl)
    
    $yOffset2 += 35
}

$disclaimerLabel = New-Object System.Windows.Forms.Label
$disclaimerLabel.Text = "⚠️ USE AT YOUR OWN RISK"
$disclaimerLabel.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$disclaimerLabel.ForeColor = [System.Drawing.Color]::FromArgb(248, 113, 113)
$disclaimerLabel.Size = New-Object System.Drawing.Size(520, 25)
$disclaimerLabel.Location = New-Object System.Drawing.Point(15, 155)
$disclaimerLabel.TextAlign = "MiddleCenter"
$creditsCard.Controls.Add($disclaimerLabel)

# ==============================================================================
# LAUNCH BUTTON
# ==============================================================================
$launchBtn = New-Object System.Windows.Forms.Button
$launchBtn.Text = "▶  LAUNCH SSTOOLSHUB"
$launchBtn.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$launchBtn.Size = New-Object System.Drawing.Size(340, 50)
$launchBtn.Location = New-Object System.Drawing.Point(120, 420)
$launchBtn.BackColor = $primary
$launchBtn.ForeColor = $white
$launchBtn.FlatStyle = "Flat"
$launchBtn.FlatAppearance.BorderSize = 0
$launchBtn.Cursor = [System.Windows.Forms.Cursors]::Hand
$mainPanel.Controls.Add($launchBtn)

$launchBtn.Add_MouseEnter({ $launchBtn.BackColor = $primaryLight })
$launchBtn.Add_MouseLeave({ $launchBtn.BackColor = $primary })

$launchBtn.Add_Click({
    Start-Process powershell.exe -ArgumentList "-NoExit", "-ep", "bypass", "-c", "irm https://raw.githubusercontent.com/3ntrsquad/SSToolsHub/refs/heads/main/SSToolsHub.ps1 | iex"
    $form.Close()
})

# ==============================================================================
# KEYBOARD SHORTCUTS
# ==============================================================================
$form.Add_KeyDown({
    if ($_.KeyCode -eq "Escape") { $form.Close() }
    if ($_.KeyCode -eq "Enter") { 
        Start-Process powershell.exe -ArgumentList "-NoExit", "-ep", "bypass", "-c", "irm https://raw.githubusercontent.com/3ntrsquad/SSToolsHub/refs/heads/main/SSToolsHub.ps1 | iex"
        $form.Close()
    }
})

# ==============================================================================
# SHOW
# ==============================================================================
$form.ShowDialog() | Out-Null
