# generisanje nasumicnog broja
broj = rand(1:10)
pogodak = 0

# promptuje se za nagadjanje dok se ne pogodi broj 
while pogodak != broj
    print("Pogodite broj izmedju 1 i 10: ")
    global pogodak = parse(Int64, readline())

    if abs(broj - pogodak) <= 1 && broj != pogodak
        print("\n")
        println("Blizu ste!")
    end
end

print("Uspeli ste!")
