# 🚗 Analyse économétrique des défaillances d'entreprises en France (1990–2024)

**Auteur :** Hugo Schneider  
**Date :** 7 février 2025  
**Cours :** Économétrie des données de panel  

---

## 🌟 Objectif du projet

Ce projet vise à analyser les facteurs macroéconomiques expliquant les faillites d’entreprises en France, à travers une étude de données trimestrielles entre 1990 et 2024.  
L’accent est mis sur deux variables clés : le taux de chômage et le produit intérieur brut (PIB). À l’aide de modèles dynamiques (OLS, ARDL, ECM), l’objectif est d’identifier les effets de court et long terme de ces variables sur le nombre de défaillances d’entreprises.

---

## 📊 Données

### 🔗 Source
- INSEE – Institut National de la Statistique et des Études Économiques

### ⏱ Fréquence et période
- Données trimestrielles, de 1990 T1 à 2024 T3

### 📄 Variables utilisées

| Variable                  | Description |
|--------------------------|-------------|
| `business_failures`      | Nombre de défaillances d’entreprises en France |
| `Unemployment_rate`      | Taux de chômage trimestriel (corrigé des variations saisonnières) |
| `Gross_domestic_product` | Produit Intérieur Brut (PIB) en milliards d’euros |

### 📈 Statistiques descriptives
- Faillites : entre 371 et 2399, moyenne ≈ 1290
- Chômage : entre 7.1% et 10.7%, moyenne ≈ 9.0%
- PIB : entre 389 et 650,9 milliards €

---

## 🔢 Méthodologie

### 🔍 Tests de stationnarité
- Test ADF appliqué à chaque série
- Toutes les variables sont non stationnaires au niveau
- Après différenciation : stationnarité obtenue → intégration d’ordre 1 (I(1))

### ⚙️ Modèles estimés

#### 1. Régression linéaire (OLS)

business_failures = β₀ + β₁ × Unemployment_rate + β₂ × GDP + ε

- Unemployment_rate : effet positif et significatif
- PIB : effet négatif et significatif
- R² = 0.772
- Problèmes d’autocorrélation (DW = 0.317) et hétéroscédasticité (p < 0.01)

#### 2. Modèle ARDL

d(business_failures) = β₀ + β₁ × L(business_failures, 1) + β₂ × d(Unemployment_rate) + β₃ × d(GDP) + ε

- Lags significatifs
- Variation du chômage : effet très fort
- PIB non significatif en variation
- R² ajusté ≈ 0.12, pas d’autocorrélation (DW ≈ 2.24)

#### 3. Modèle ECM

d(business_failures) = β₀ + β₁ × d(Unemployment_rate) + β₂ × d(GDP) + β₃ × L(ecm) + ε

- L(ecm) : coefficient négatif significatif → retour à l’équilibre
- Variation du chômage toujours significative
- R² ≈ 0.11, aucun problème de résidus

---

## 🔄 Résumé des résultats

| Modèle | Variables significatives     | Interprétation principale |
|--------|------------------------------|----------------------------|
| OLS    | Chômage (+), PIB (−)         | Hausse du chômage = + faillites ; croissance = − faillites |
| ARDL   | d(Chômage) (+)               | Réaction immédiate aux chocs de chômage |
| ECM    | L(ecm) (−), d(Chômage) (+)   | Ajustement vers l’équilibre + effet conjoncturel du chômage |

---

## ⚠️ Limites

- Modèle OLS : autocorrélation et hétéroscédasticité
- Modèles dynamiques : faible pouvoir explicatif (R² < 0.15)
- Variables absentes : taux d’intérêt, investissement, aides publiques

---

## 📚 Conclusion

Cette étude démontre que le chômage est un déterminant majeur des faillites d’entreprises en France.  
Une hausse du chômage accroît fortement le risque de défaillance, tandis que la croissance du PIB contribue à réduire ces faillites.

Les modèles dynamiques montrent que les effets sont à la fois immédiats (ARDL) et ajustés dans le temps (ECM).  
Les politiques économiques de soutien à l’emploi et à l’activité apparaissent donc cruciales pour limiter les défaillances.

> ✅ Une stratégie combinée de lutte contre le chômage et de stimulation de la croissance permettrait de contenir les faillites d’entreprises sur le long terme.

