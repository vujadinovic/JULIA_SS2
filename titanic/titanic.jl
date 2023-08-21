using Pkg
Pkg.add("DataFrames")
Pkg.add("CSV")

using DataFrames, CSV


# Proveriti na kom mestu u fajl sistemu se nalazimo pomocu pwd()
# i zatim promeniti na odgovarajuce pomocu cd("put_do_zeljenog_foldera")
# pwd()
# cd("")



trainDf = CSV.read("train.csv", DataFrame)

#-------------------SREDJIVANJE PODATAKA-------------------#

# U Embarked koloni fale samo dve vrednosti,
# pa mozemo te dve vrste u potpunosti odbaciti jer ne gubimo mnogo informacija 
trainDf = dropmissing(trainDf, "Embarked")


# Vrednosti Age kolone ne mozemo odbaciti tek tako jer nedostaje 177 vrednosti,
# zamenimo ih medijanom
trainDf.Age = replace(trainDf.Age, missing => 28)


# Cabin koloni fali 687 vrednosti sto je preko pola skupa podataka,
# to je premalo informacija i potpuno izbacujemo ovu kolonu
trainDf = select(trainDf, Not("Cabin"))

# NEBROJEVNI PODACI

# Ime i ID su jedinstveni za svakog putnika pa ne mogu biti upotrebljeni 
# u ML modelu, stoga odmacimo ih
trainDf = select(trainDf, Not(["PassengerId", "Name"]))


# S, C i Q su jedine vrednosti za Embarked kolonu
# pa ih kodirajmo brojevima
trainDf.Embarked = Int64.(
    replace(trainDf.Embarked,
    "S" => 1, "C" => 2, "Q" => 3
    )
)

# Slicno za Sex kolonu
trainDf.Sex = Int64.(
    replace(trainDf.Sex, 
        "female" => 1, "male" => 2
    )
)

# Ticket kolona ima 680 razlicitih kategorija, 
# sto je teze (mada moguce) pretvoriti u nesto korisno za model,
# pa cemo radi jednostavnosti izbaciti i ovu kolonu
trainDf = select(trainDf, Not("Ticket"))


#-------------------TRENIRANJE MODELA-------------------#

# Koristicemo SciKitLearn.jl biblioteku,
# koja oponasa poznatu SciKit-Learn za Python.
# Specijalno, treba nam RandomForestClassifier model iz DecisionTree.jl paketa
# (posto je ovo problem klasifikacije) i CrossValidation da izracunamo tacnost modela.
Pkg.add("DecisionTree")
Pkg.add("ScikitLearn")
using DecisionTree, ScikitLearn.CrossValidation


# PODELIMO SKUP PODATAKA NA ATRIBUTE I CILJNE PROMENLJIVE

# Survived je ciljna promenljiva
y = trainDf[:, "Survived"]

# Ostale kolone su atributi
X = Matrix(trainDf[:, Not(["Survived"])])

model = RandomForestClassifier(n_trees=100)

fit!(model, X, y)

accuracy = minimum(
    cross_val_score(model, X, y, cv=5)
)

println(accuracy)



#-------------------PRIMENA MODELA-------------------#


testDf = CSV.read("test.csv", DataFrame)

PassengerId = testDf[:,"PassengerId"]

# SREDJIVANJE TEST PODATAKA
testDf = select(testDf,
    Not(
        ["PassengerId","Name","Ticket","Cabin"]
    )
)
testDf.Age = replace(testDf.Age,missing=>28)
testDf.Embarked = replace(
    testDf.Embarked,"S" => 1, "C" => 2, "Q" => 3
)
testDf.Embarked = convert.(Int64,testDf.Embarked)
testDf.Sex = replace(
    testDf.Sex,"female" => 1,"male" => 2
)
testDf.Sex = convert.(Int64,testDf.Sex)

testDf.Fare = replace(
    testDf.Fare,
    missing=>14.4542 # medijana
)


# Konacno, predvidjanje:
Survived = predict(model, Matrix(testDf)) 


# Ispisivanje predvidjanja u CSV datoteku
predvidjanjeDf = DataFrame(PassengerId=PassengerId,Survived=Survived)
CSV.write("predvidjanje.csv", predvidjanjeDf)

println("Uspesno zavrseno.")