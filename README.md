# LazyBrush-implementation
A study and implementation of ['LazyBrush: Flexible Painting Tool for Hand-drawn Cartoons'](http://dcgi.felk.cvut.cz/home/sykorad/Sykora09-EG.pdf) for the course 'Introduction à l'image numérique' of the Master 2 'Mathématiques, Vision, Apprentissage' at ENS Cachan (France), 2015-2016.

Questions, issues, suggestions, contact? [simonrodriguez.fr](http://simonrodriguez.fr)

More details (in french) below.

## Utilisation

`lazybrush(base_name,mode,save)` (voir détail des arguments ci-dessous)

Des images et tracés sont disponibles dans le répertoire `images`. L'image sera convertie en niveaux de gris. Les tracés doivent être réalisés dans un fichier png transparent, il est important d'utiliser un outil net/dur pour les tracer (par exemple sous Photoshop il convient d'utiliser le crayon et non le pinceau).

## Fonctions
- `[result] = lazybrush( base_name, mode, save )`  
	Fonction principale.  	**Entrées :**	- le nom de base de l’image à traiter (sans extension). L’algorithme attend que les images `base_name.png` et `base_name_brushes.png` existent.	- le mode de mise à l’échelle. 0 : linéaire, 1 : quadratique, 2 : LoG.	- un booléen indiquant si le résultat doit être sauvegardée. L’image créée sera sauvegardée sous base name output.png   
	
	**Sortie :**
		- L’image colorisée sous forme de matrice h*w*3 à valeurs dans [0,255].
	- `[I, M, B, C, intensity, im_overlay] = createVariables( imagePath, brushPath, scaling, verbose )`  Génère les variables nécessaires pour la suite des opérations.  	**Entrées :**	- le chemin complet vers le dessin.	- le chemin complet vers l’image contenant les tracés de couleur	- le type de mise à l’échelle (voir ci-dessus)	- un booléen indiquant si des informations supplémentaires doivent être affichées ou non
		**Sorties :**
		- une image en niveaux de gris à valeurs dans [1;K]	- un masque, initialisé avec des zéros	- une image indiquant pour chaque pixel l’indice de la couleur éventuelle du trait coloré le recouvrant, 0 sinon	- une liste des couleurs avec leurs indices correspondants	- l’image initiale en niveaux de gris	- l’image initiale en niveaux de gris sur laquelle les traits colorés ont été superposés
	
- `[J] = colorize( I, M, B, C, mix, verbose )`  
	Effectue la colorisation.  	**Entrées :**	- I, M, B, C comme décrit ci-dessus	- un coefficient de mélange utilisé pour le calcul des poids de chaque arête	- un booléen indiquant si des informations supplémentaires doivent être affichées ou non.
		**Sortie :**
		- une image contenant pour chaque pixel l’indice de la couleur qui lui a été attribuée
	- `[G, indices, S, T]  = buildGraph(M, I, mix)  `Construit un graphe en utilisant les pixels non masqués de M et les valeurs d’intensité contenues dans I.  	**Entrées :**	- un masque (partiellement rempli)	- l’image mise à l’échelle	- un coefficient de mélange utilisé pour le calcul des poids de chaque arête 
	 	**Sortie :**
		- un graphe	- les indices (i,j) correspondant à chaque noeud du graphe	- la valeur pour le noeud S	- la valeur pour le noeud T
	- `[M] = simplifyMask(G0,M,B,indices)`  Détecte dans un graphe des cliques de pixels qui ne touchent des traits que d’une unique couleur, et remplit dans le masque les zones correspondantes.   	**Entrées :**	- un graphe	- un masque	- une image indiquant pour chaque pixel l’indice de la couleur éventuelle du trait coloré le recouvrant, 0 sinon	- les indices (i,j) correspondant à chaque noeud du graphe
	  
	**Sortie :**
		- le masque modifié
