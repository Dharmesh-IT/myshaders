function Show-AdvancedProgressBar {
    param (
        [int]$total = 100, # Total percentage (100%)
        [int]$width = 50, # Width of the progress bar
        [int]$speed = 50, # Speed of the progress bar (smaller = faster)
        [int]$sleepInterval = 100         # Time in milliseconds between updates
    )

    $progress = 0
    $colorStart = "Green"               # Start color (Green)
    $colorEnd = "Red"                   # End color (Red)
    $transitionColors = @("Green", "Yellow", "Orange", "Red")  # Color gradient during transition

    # Function to dynamically adjust the color based on progress
    function Get-DynamicColor {
        param ([int]$progress)
        
        if ($progress -lt 25) {
            return $transitionColors[0]  # Green
        }
        elseif ($progress -lt 50) {
            return $transitionColors[1]  # Yellow
        }
        elseif ($progress -lt 75) {
            return $transitionColors[2]  # Orange
        }
        else {
            return $transitionColors[3]  # Red
        }
    }

    # Main loop to update the progress bar
    while ($progress -le $total) {
        # Calculate the number of filled and empty parts of the progress bar
        $filled = [math]::Floor($progress * $width / $total)
        $empty = $width - $filled

        # Generate the progress bar string
        $bar = ("#" * $filled) + (" " * $empty)

        # Get the dynamic color based on progress
        $currentColor = Get-DynamicColor -progress $progress

        # Clear the line and update the progress bar in place
        Write-Host -NoNewline "`r[" + ($bar.Substring(0, $filled)) + ($bar.Substring($filled)) + "]"

        # Apply color to the filled portion
        Write-Host -NoNewline ("#" * $filled) -ForegroundColor $currentColor

        # Apply color to the empty portion (Gray)
        Write-Host -NoNewline (" " * $empty) -ForegroundColor "Gray"

        # Display the percentage with color
        Write-Host -NoNewline " $progress%" -ForegroundColor White

        # Increment the progress and wait a bit before updating again
        $progress += 1
        Start-Sleep -Milliseconds $sleepInterval
    }

    # Final message once the progress is completed
    Write-Host "`nDone!" -ForegroundColor Yellow
}

# Call the function to display the advanced progress bar
Show-AdvancedProgressBar -total 100 -width 50 -speed 50 -sleepInterval 100
