# Origins

The original implementation of Solar Credit's algorithm was my request to ChatGPT. Due to its complexity, it was beyond my understanding of how to actually write it. I've written algorithms before, but those were in C#. GDScript is still a little foreign to me.

It took some trial and error to get it right. In fact, my original requests were to Bing Copilot, where I simply asked it to search GDScript documentation and use that to write a script that simulates energy demand and converts it into currency. However, it gave me links to it instead of using it as a reference. Regardless, the code did work.

After requesting a few refactorings that involved storing the energy into a battery, which would be converted into money, I looked to ChatGPT. I requested what I wanted based on my experience with Bing Copilot, and it worked the first time. Below is the bot's code and explanation.

## ChatGPT

### Sample Code

```gdscript
extends Node

var battery_percentage: float = 0.0
var wallet: int = 0
var generating_energy: bool = true

func _ready():
    # Start the game loop
    set_process(true)

func _process(delta):
    if generating_energy:
        generate_energy(delta)
    else:
        consume_energy(delta)
    check_wallet()
    print_status()

func generate_energy(delta):
    if battery_percentage < 500.0:
        battery_percentage += 10.0 * delta
        if battery_percentage >= 500.0:
            battery_percentage = 500.0
            generating_energy = false
            add_to_wallet()
    else:
        generating_energy = false

func consume_energy(delta):
    battery_percentage -= 5.0 * delta
    if battery_percentage <= 250.0:
        battery_percentage = 250.0
        generating_energy = true

func add_to_wallet():
    var earned_credits = rand_range(100, 200)
    wallet += earned_credits
    if wallet > 1000:
        wallet = 1000
    elif wallet > 300:
        wallet -= sell_energy(wallet - 300)

func sell_energy(amount):
    # Simulate selling the energy for credits
    return int(amount * 0.5)

func check_wallet():
    # Ensure the wallet does not exceed the limit
    if wallet > 1000:
        wallet = 1000

func print_status():
    print("Battery: " + str(battery_percentage) + "%, Wallet: " + str(wallet) + " Credits")
```

### Explanation

1. **Variables**:

   - `battery_percentage`: Represents the battery charge level (0.0 to 500.0).
   - `wallet`: Holds the number of "Credits" earned.
   - `generating_energy`: A boolean to control energy generation.

2. **Game Loop**:

   - The `_process` function is called every frame, using the `delta` value to ensure consistent updates across different frame rates.

3. **Energy Generation**:

   - The `generate_energy` function increases the battery level until it reaches 500.0, at which point it stops generating energy.

4. **Energy Consumption**:

   - The `consume_energy` function reduces the battery level until it drops to 250.0, at which point energy generation resumes.

5. **Wallet Management**:

   - `add_to_wallet` converts generated energy into credits and adds them to the wallet. It ensures that the wallet balance stays within the 0 to 1000 range.

6. **Sell Energy**:
   - The `sell_energy` function is a placeholder to simulate selling excess energy.

This code will print the battery percentage and wallet amount to the console every frame, simulating the energy management system you've described. The logic ensures that variables never dip into the negatives and respects the wallet and battery limits.
