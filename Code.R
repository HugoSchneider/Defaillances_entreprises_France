# Chargement des bibliothèques
library(readxl)
library(dplyr)
library(tidyr)
library(lubridate)
library(zoo)
library(lmtest)
library(sandwich)
library(tseries)
library(ggplot2)
library(stargazer)

# Définition du répertoire de travail
setwd("/Users/schneiderhugo/Desktop")

# Chargement des données
data <- read_excel("Données.xlsx")

# Conversion des variables en numériques
data$business_failures <- as.numeric(data$business_failures)
data$Unemployment_rate <- as.numeric(data$Unemployment_rate)
data$Gross_domestic_product <- as.numeric(data$Gross_domestic_product)

# Vérification et correction de la colonne temporelle
data$Year_Trimestre <- as.yearqtr(as.character(data$Year_Trimestre), format = "%Y-T%q")

# Statistiques descriptives
summary(data)

# Vérification de la stationnarité avec le test de Dickey-Fuller (ADF)
adf.test(data$business_failures)
adf.test(data$Unemployment_rate)
adf.test(data$Gross_domestic_product)

# Si les séries ne sont pas stationnaires, on applique la différenciation
data$business_failures_diff <- c(NA, diff(data$business_failures))
data$Unemployment_rate_diff <- c(NA, diff(data$Unemployment_rate))
data$Gross_domestic_product_diff <- c(NA, diff(data$Gross_domestic_product))

# Vérification après différenciation
adf.test(na.omit(data$business_failures_diff))
adf.test(na.omit(data$Unemployment_rate_diff))
adf.test(na.omit(data$Gross_domestic_product_diff))

# Régression OLS classique
model_ols <- lm(business_failures ~ Unemployment_rate + Gross_domestic_product, data = data)
summary(model_ols)

# Correction des erreurs avec des erreurs robustes de Newey-West
coeftest(model_ols, vcov = NeweyWest(model_ols))

# Vérification de l'autocorrélation des erreurs
dwtest(model_ols)  # Durbin-Watson Test

# Test d'hétéroscédasticité
bptest(model_ols)  # Breusch-Pagan Test

# Si l'autocorrélation et l'hétéroscédasticité sont présentes, utiliser des erreurs robustes de White
coeftest(model_ols, vcov = vcovHC(model_ols, type = "HC1"))

# Visualisation des variables
ggplot(data, aes(x = Year_Trimestre, y = business_failures, group = 1)) +
  geom_line(color = "blue") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  labs(title = "Évolution des Défaillances d'Entreprises en France",
       x = "Trimestre",
       y = "Nombre de faillites")

ggplot(data, aes(x = Unemployment_rate, y = business_failures)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE, color = "blue") +
  labs(title = "Lien entre Taux de Chômage et Défaillances d'Entreprises",
       x = "Taux de chômage (%)",
       y = "Défaillances d'entreprises")

ggplot(data, aes(x = Gross_domestic_product, y = business_failures)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE, color = "red") +
  labs(title = "Lien entre PIB et Défaillances d'Entreprises",
       x = "PIB (%)",
       y = "Défaillances d'entreprises")


str(data$Year_Trimestre)  # Vérifie le type de la colonne
table(data$Year_Trimestre)  # Vérifie les valeurs uniques

data_panel <- pdata.frame(data, index = c("Country", "Year_Trimestre"))


# Modèle à Effets Fixes
model_fixed <- plm(business_failures ~ Unemployment_rate + Gross_domestic_product, 
                   data = data_panel, model = "within")
summary(model_fixed)


library(urca)  # Pour tester la cointégration
library(dynlm)  # Modèle ECM

# Vérifier la cointégration entre les variables
coint_test <- ca.jo(data[, c("business_failures", "Unemployment_rate", "Gross_domestic_product")], type = "trace", K = 2)
summary(coint_test)


# Chargement des bibliothèques nécessaires
library(dynlm)
library(zoo)

# Estimation de la relation de long terme
long_run_model <- lm(business_failures ~ Unemployment_rate + Gross_domestic_product, data = data)
data$ecm <- residuals(long_run_model)  # Création du terme d'erreur

# Ajouter `ecm` à `data_zoo`
data_zoo$ecm <- coredata(data$ecm)  # S'assurer que `ecm` est bien aligné

# Vérifier que `ecm` est bien ajouté
head(data_zoo)

# Modèle ECM avec `dynlm()`
model_ecm <- dynlm(d(business_failures) ~ d(Unemployment_rate) + d(Gross_domestic_product) + L(ecm, 1), data = data_zoo)

# Résumé des résultats
summary(model_ecm)

# Comparaison avec un modèle ARDL si nécessaire

# Définition des séries temporelles avec index trimestriel
data_zoo <- zoo(data[, c("business_failures", "Unemployment_rate", "Gross_domestic_product")],
                order.by = as.yearqtr(data$Year_Trimestre, format = "%Y-T%q"))
data_zoo

# Vérification de la conversion
head(data_zoo)
library(dynlm)
model_ardl <- dynlm(d(business_failures) ~ L(business_failures, 1) + d(Unemployment_rate) + d(Gross_domestic_product), data = data_zoo)
summary(model_ardl)


# Exportation des résultats sous format CSV et LaTeX
write.csv(summary(model_ols)$coefficients, "resultats_OLS.csv")
write.csv(summary(model_ecm)$coefficients, "resultats_ECM.csv")
write.csv(summary(model_ardl)$coefficients, "resultats_ARDL.csv")


stargazer(model_ols, model_ecm, model_ardl, type = "text", title = "Comparaison des Modèles")


