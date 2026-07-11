

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Runtime.InteropServices

# ==============================================================================
# WIN32 – Rounded Corners & Drag
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
# CUSTOM GRADIENT BUTTON
# ==============================================================================
Add-Type -TypeDefinition @"
using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Windows.Forms;

public class GradientButton : Button {
    private Color color1 = Color.FromArgb(124, 58, 237);
    private Color color2 = Color.FromArgb(79, 70, 229);
    private Color hoverColor1 = Color.FromArgb(139, 92, 246);
    private Color hoverColor2 = Color.FromArgb(124, 58, 237);
    private int cornerRadius = 29;
    private bool isHovered = false;

    public GradientButton() {
        this.FlatStyle = FlatStyle.Flat;
        this.FlatAppearance.BorderSize = 0;
        this.BackColor = Color.Transparent;
        this.SetStyle(ControlStyles.AllPaintingInWmPaint | ControlStyles.UserPaint | ControlStyles.ResizeRedraw | ControlStyles.DoubleBuffer, true);
    }

    protected override void OnPaint(PaintEventArgs e) {
        base.OnPaint(e);
        Graphics g = e.Graphics;
        g.SmoothingMode = SmoothingMode.AntiAlias;
        Rectangle rect = new Rectangle(0, 0, this.Width, this.Height);
        
        GraphicsPath path = new GraphicsPath();
        int r = cornerRadius;
        int w = this.Width;
        int h = this.Height;
        path.AddArc(0, 0, r, r, 180, 90);
        path.AddArc(w - r, 0, r, r, 270, 90);
        path.AddArc(w - r, h - r, r, r, 0, 90);
        path.AddArc(0, h - r, r, r, 90, 90);
        path.CloseFigure();
        
        this.Region = new Region(path);
        
        Color c1 = isHovered ? hoverColor1 : color1;
        Color c2 = isHovered ? hoverColor2 : color2;
        LinearGradientBrush brush = new LinearGradientBrush(rect, c1, c2, LinearGradientMode.Horizontal);
        g.FillPath(brush, path);
        brush.Dispose();
        
        // Glow border
        Color borderColor = isHovered ? Color.FromArgb(200, 139, 92, 246) : Color.FromArgb(100, 139, 92, 246);
        using (Pen pen = new Pen(borderColor, 2)) {
            g.DrawPath(pen, path);
        }
        
        // Text
        StringFormat sf = new StringFormat();
        sf.Alignment = StringAlignment.Center;
        sf.LineAlignment = StringAlignment.Center;
        using (SolidBrush textBrush = new SolidBrush(Color.White)) {
            g.DrawString(this.Text, this.Font, textBrush, rect, sf);
        }
        path.Dispose();
    }

    protected override void OnMouseEnter(EventArgs e) {
        isHovered = true;
        this.Invalidate();
        base.OnMouseEnter(e);
    }

    protected override void OnMouseLeave(EventArgs e) {
        isHovered = false;
        this.Invalidate();
        base.OnMouseLeave(e);
    }
}
"@ -ReferencedAssemblies "System.Windows.Forms.dll","System.Drawing.dll","System.dll"

# ==============================================================================
# COLOR PALETTE
# ==============================================================================
$colors = @{
    bg          = [System.Drawing.Color]::FromArgb(12, 12, 25)
    glass       = [System.Drawing.Color]::FromArgb(30, 30, 50)
    glassLight  = [System.Drawing.Color]::FromArgb(45, 40, 65)
    primary1    = [System.Drawing.Color]::FromArgb(124, 58, 237)
    primary2    = [System.Drawing.Color]::FromArgb(79, 70, 229)
    primary3    = [System.Drawing.Color]::FromArgb(139, 92, 246)
    accent      = [System.Drawing.Color]::FromArgb(6, 182, 212)
    accent2     = [System.Drawing.Color]::FromArgb(34, 211, 238)
    text        = [System.Drawing.Color]::FromArgb(235, 235, 245)
    textSec     = [System.Drawing.Color]::FromArgb(180, 180, 210)
    textMuted   = [System.Drawing.Color]::FromArgb(110, 110, 140)
    white       = [System.Drawing.Color]::White
    titleGlow   = [System.Drawing.Color]::FromArgb(210, 190, 255)
    danger      = [System.Drawing.Color]::FromArgb(248, 113, 113)
    discord     = [System.Drawing.Color]::FromArgb(88, 101, 242)
    minecraft   = [System.Drawing.Color]::FromArgb(74, 222, 128)
    gold        = [System.Drawing.Color]::FromArgb(251, 191, 36)
    shadow      = [System.Drawing.Color]::FromArgb(124, 58, 237, 60)
}

# ==============================================================================
# FORM
# ==============================================================================
$form = New-Object System.Windows.Forms.Form
$form.Text = "SSToolsHub Launcher"
$form.Size = New-Object System.Drawing.Size(620, 660)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "None"
$form.BackColor = $colors.bg
$form.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$form.TopMost = $true
$form.Add_Shown({ Make-Rounded -control $form -radius 28 })

# ==============================================================================
# TITLE BAR
# ==============================================================================
$titleBar = New-Object System.Windows.Forms.Panel
$titleBar.Size = New-Object System.Drawing.Size(620, 60)
$titleBar.Location = New-Object System.Drawing.Point(0, 0)
$titleBar.BackColor = [System.Drawing.Color]::FromArgb(20, 20, 40)
$form.Controls.Add($titleBar)

$glowLine = New-Object System.Windows.Forms.Label
$glowLine.Size = New-Object System.Drawing.Size(620, 2)
$glowLine.Location = New-Object System.Drawing.Point(0, 58)
$glowLine.BackColor = $colors.primary1
$glowLine.Text = ""
$titleBar.Controls.Add($glowLine)

$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = "✦ SSToolsHub Launcher"
$titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 20, [System.Drawing.FontStyle]::Bold)
$titleLabel.ForeColor = $colors.titleGlow
$titleLabel.Size = New-Object System.Drawing.Size(500, 60)
$titleLabel.Location = New-Object System.Drawing.Point(20, 0)
$titleLabel.TextAlign = "MiddleLeft"
$titleLabel.BackColor = [System.Drawing.Color]::Transparent
$titleBar.Controls.Add($titleLabel)

$subTitle = New-Object System.Windows.Forms.Label
$subTitle.Text = "Ultimate Forensic Tool Hub"
$subTitle.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Italic)
$subTitle.ForeColor = $colors.textMuted
$subTitle.Size = New-Object System.Drawing.Size(200, 20)
$subTitle.Location = New-Object System.Drawing.Point(225, 35)
$subTitle.TextAlign = "MiddleLeft"
$subTitle.BackColor = [System.Drawing.Color]::Transparent
$titleBar.Controls.Add($subTitle)

$closeBtn = New-Object System.Windows.Forms.Button
$closeBtn.Text = "✕"
$closeBtn.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$closeBtn.Size = New-Object System.Drawing.Size(40, 40)
$closeBtn.Location = New-Object System.Drawing.Point(570, 10)
$closeBtn.FlatStyle = "Flat"
$closeBtn.FlatAppearance.BorderSize = 0
$closeBtn.BackColor = [System.Drawing.Color]::Transparent
$closeBtn.ForeColor = $colors.textMuted
$closeBtn.Cursor = [System.Windows.Forms.Cursors]::Hand
$closeBtn.Add_Click({ $form.Close() })
$closeBtn.Add_MouseEnter({ 
    $closeBtn.ForeColor = $colors.danger
    $closeBtn.BackColor = [System.Drawing.Color]::FromArgb(40, 20, 20)
})
$closeBtn.Add_MouseLeave({ 
    $closeBtn.ForeColor = $colors.textMuted
    $closeBtn.BackColor = [System.Drawing.Color]::Transparent
})
$titleBar.Controls.Add($closeBtn)

$titleBar.Add_MouseDown({
    if ($_.Button -eq [System.Windows.Forms.MouseButtons]::Left) {
        [Win32]::ReleaseCapture()
        [Win32]::SendMessage($form.Handle, 0xA1, 0x2, 0)
    }
})

# ==============================================================================
# MAIN CONTENT
# ==============================================================================
$mainPanel = New-Object System.Windows.Forms.Panel
$mainPanel.Size = New-Object System.Drawing.Size(600, 580)
$mainPanel.Location = New-Object System.Drawing.Point(10, 65)
$mainPanel.BackColor = [System.Drawing.Color]::Transparent
$mainPanel.AutoScroll = $true
$form.Controls.Add($mainPanel)

# ==============================================================================
# GLASS CARD HELPER
# ==============================================================================
function New-GlassCard {
    param($x, $y, $w, $h)
    $card = New-Object System.Windows.Forms.Panel
    $card.Size = New-Object System.Drawing.Size($w, $h)
    $card.Location = New-Object System.Drawing.Point($x, $y)
    $card.BackColor = [System.Drawing.Color]::FromArgb(25, 25, 45)
    $card.Add_Paint({
        $g = $_.Graphics
        $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $rect = New-Object System.Drawing.Rectangle(0, 0, $card.Width, $card.Height)
        $path = New-Object System.Drawing.Drawing2D.GraphicsPath
        $r = 20
        $w2 = $card.Width
        $h2 = $card.Height
        $path.AddArc(0, 0, $r, $r, 180, 90)
        $path.AddArc($w2 - $r, 0, $r, $r, 270, 90)
        $path.AddArc($w2 - $r, $h2 - $r, $r, $r, 0, 90)
        $path.AddArc(0, $h2 - $r, $r, $r, 90, 90)
        $path.CloseFigure()
        
        $fillBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(220, 25, 25, 45))
        $g.FillPath($fillBrush, $path)
        $fillBrush.Dispose()
        
        $borderBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(60, 124, 58, 237))
        $g.DrawPath((New-Object System.Drawing.Pen($borderBrush, 1.5)), $path)
        $borderBrush.Dispose()
        $path.Dispose()
    })
    return $card
}

function New-GlassLabel {
    param($text, $x, $y, $w, $h, $fs = 10, $bold = $false, $color = $null, $align = "MiddleLeft")
    if (-not $color) { $color = $colors.text }
    $style = if ($bold) { [System.Drawing.FontStyle]::Bold } else { [System.Drawing.FontStyle]::Regular }
    $label = New-Object System.Windows.Forms.Label
    $label.Text = $text
    $label.Font = New-Object System.Drawing.Font("Segoe UI", $fs, $style)
    $label.ForeColor = $color
    $label.Size = New-Object System.Drawing.Size($w, $h)
    $label.Location = New-Object System.Drawing.Point($x, $y)
    $label.TextAlign = [System.Drawing.ContentAlignment]$align
    $label.BackColor = [System.Drawing.Color]::Transparent
    return $label
}

# ==============================================================================
# CARDS
# ==============================================================================
$welcomeCard = New-GlassCard 20 10 560 75
$mainPanel.Controls.Add($welcomeCard)
$welcomeCard.Controls.Add((New-GlassLabel -text "✨ Welcome to SSToolsHub" -x 20 -y 8 -w 520 -h 30 -fs 18 -bold $true -color $colors.white -align "MiddleLeft"))
$welcomeCard.Controls.Add((New-GlassLabel -text "Premium Forensic Tool Hub • Powered by 3NTR" -x 20 -y 42 -w 520 -h 25 -fs 11 -bold $false -color $colors.textSec -align "MiddleLeft"))

$toolCard = New-GlassCard 20 95 560 115
$mainPanel.Controls.Add($toolCard)
$toolCard.Controls.Add((New-GlassLabel -text "📌 TOOL INFORMATION" -x 20 -y 8 -w 520 -h 28 -fs 13 -bold $true -color $colors.accent -align "MiddleLeft"))
$toolInfo = @(
    "🔧 These tools are NOT created by me",
    "📚 All tools belong to their respective authors",
    "⚖️ Provided for educational and forensic purposes only"
)
$yOff = 42
foreach ($line in $toolInfo) {
    $toolCard.Controls.Add((New-GlassLabel -text $line -x 20 -y $yOff -w 520 -h 22 -fs 10 -bold $false -color $colors.textSec -align "MiddleLeft"))
    $yOff += 24
}

$creditsCard = New-GlassCard 20 220 560 200
$mainPanel.Controls.Add($creditsCard)
$creditsCard.Controls.Add((New-GlassLabel -text "👤 MY INFORMATION" -x 20 -y 8 -w 520 -h 28 -fs 13 -bold $true -color $colors.primary3 -align "MiddleLeft"))
$credits = @(
    @{ Icon = "💬"; Label = "Discord"; Value = "@unseentracking"; Color = $colors.discord },
    @{ Icon = "⛏️"; Label = "Minecraft"; Value = "3ntrsquad"; Color = $colors.minecraft },
    @{ Icon = "🎯"; Label = "Bio"; Value = "HEAD SSER in OrbitalFFA"; Color = $colors.gold }
)
$yOff2 = 42
foreach ($item in $credits) {
    $creditsCard.Controls.Add((New-GlassLabel -text $item.Icon -x 20 -y $yOff2 -w 35 -h 32 -fs 16 -bold $false -color $colors.white -align "MiddleLeft"))
    $creditsCard.Controls.Add((New-GlassLabel -text "$($item.Label):" -x 60 -y $yOff2 -w 90 -h 32 -fs 11 -bold $true -color $colors.text -align "MiddleLeft"))
    $creditsCard.Controls.Add((New-GlassLabel -text $item.Value -x 155 -y $yOff2 -w 380 -h 32 -fs 11 -bold $true -color $item.Color -align "MiddleLeft"))
    $yOff2 += 38
}
$creditsCard.Controls.Add((New-GlassLabel -text "⚠️ USE AT YOUR OWN RISK" -x 20 -y 162 -w 520 -h 28 -fs 12 -bold $true -color $colors.danger -align "MiddleCenter"))

# ==============================================================================
# STATUS INDICATOR
# ==============================================================================
$statusPanel = New-Object System.Windows.Forms.Panel
$statusPanel.Size = New-Object System.Drawing.Size(560, 30)
$statusPanel.Location = New-Object System.Drawing.Point(20, 430)
$statusPanel.BackColor = [System.Drawing.Color]::Transparent
$mainPanel.Controls.Add($statusPanel)

$statusDot = New-Object System.Windows.Forms.Panel
$statusDot.Size = New-Object System.Drawing.Size(10, 10)
$statusDot.Location = New-Object System.Drawing.Point(5, 10)
$statusDot.BackColor = [System.Drawing.Color]::FromArgb(74, 222, 128)
$statusDot.Add_Paint({
    $g = $_.Graphics
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $path.AddEllipse(0, 0, 10, 10)
    $statusDot.Region = New-Object System.Drawing.Region($path)
    $path.Dispose()
})
$statusPanel.Controls.Add($statusDot)

$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Text = "Ready to launch"
$statusLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Italic)
$statusLabel.ForeColor = $colors.textMuted
$statusLabel.Size = New-Object System.Drawing.Size(200, 30)
$statusLabel.Location = New-Object System.Drawing.Point(20, 0)
$statusLabel.TextAlign = "MiddleLeft"
$statusLabel.BackColor = [System.Drawing.Color]::Transparent
$statusPanel.Controls.Add($statusLabel)

# ==============================================================================
# CUSTOM GRADIENT LAUNCH BUTTON
# ==============================================================================
$launchBtn = New-Object GradientButton
$launchBtn.Text = "▶  LAUNCH SSTOOLSHUB"
$launchBtn.Font = New-Object System.Drawing.Font("Segoe UI", 15, [System.Drawing.FontStyle]::Bold)
$launchBtn.Size = New-Object System.Drawing.Size(400, 58)
$launchBtn.Location = New-Object System.Drawing.Point(100, 475)
$launchBtn.Cursor = [System.Windows.Forms.Cursors]::Hand
$mainPanel.Controls.Add($launchBtn)

$launchBtn.Add_Click({
    $statusDot.BackColor = $colors.gold
    $statusLabel.Text = "🚀 Launching..."
    $statusLabel.ForeColor = $colors.gold
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
