using Pkg
Pkg.add("DataFrames")
Pkg.add("Plots")
using DataFrames, Plots


# https://www.statista.com/statistics/425240/eu-car-sales-average-prices-in-by-make/
👻 = DataFrame(marka = ["Renault", "Toyota", "Volvo", "Mercedes-Benz"],
                    cena = [23081, 25480, 47111, 48413] )

println(👻)


plot(
    👻.marka,
    👻.cena,
    title="Cene automobila 2019. godine",
    label=nothing,
    seriestype="bar"
)