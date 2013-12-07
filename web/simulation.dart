

import "dart:math";
import 'dart:html';


InputElement CombienReplications, CombienEntites,TauxArrivee,TauxServeur1PremierPassage,TauxServeur2PremierPassage,TauxRetravail,
LB_TransportRetravail,UB_TransportRetravail,ProbSortie,ProbDestruction,ProbRetravail,input1,input2,input3,input4,input5,input6;

//LabelElement label1,label2,label3,label4,label5,label6 ;

ButtonElement bouton_lancer;


// DÉFINITION DES CLASSES DE LA SIMULATION

class piece {
  double HeureArrivee;
  double DebutTraitement ;
  
  double FinTraitement ;
  double HeureSortie;
  int NbTraitements = 0;
  int ServeurTraitmement = 0;
}

class serveur {
  int No ;
  piece PieceEnTraitement ;
  double SommeTempsOccupe = 0.00;
 }

class Evenement {
  double Temps;                                                                                                    
  String Libelle_Evenement ;
  int ServeurNo ;
  piece PieceTransport ;
  int NbrRTP = 0;
}

class system {
  int ReplicationNo ;
  List<Evenement> ListEvenements;  
  List<Evenement> EvenementsTraites ;
  List<piece> file ;
  serveur serveur1;
  serveur serveur2;
  List<piece> EntitesTraitees;
  List<piece> EntitesDetruites;
  double HeureDeFin;
}

class SimulationDatas {
  int CombienEntites ;
  int CombienReplications;
  double TauxServeur1PremierPassage;
  double TauxServeur2PremierPassage;
  double TauxRetravail;
  double TauxArrivee;
  double LB_TransportRetravail;
  double UB_TransportRetravail;
  double ProbSortie;
  double ProbDestruction;
  double ProbRetravail;
  
  //stockage de données de la simulation
  List<system> Resultats ;
}



main() {
  
  bind_elements();
  
  var Params = new SimulationDatas() ;     
    
  Params.Resultats = new List<system>();   
  
    Params.CombienReplications = 50;
    CombienReplications.value = Params.CombienReplications.toString();
    
    
    Params.CombienEntites = 200;
    CombienEntites.value = Params.CombienEntites.toString();
    
    Params.TauxArrivee = 4.00;
    TauxArrivee.value = Params.TauxArrivee.toString();
    
    Params.TauxServeur1PremierPassage = 2.00;
    TauxServeur1PremierPassage.value = Params.TauxServeur1PremierPassage.toString();
    
    Params.TauxServeur2PremierPassage = 1.00;
    TauxServeur2PremierPassage.value = Params.TauxServeur2PremierPassage.toString();
    
    Params.TauxRetravail = 5.00;
    TauxRetravail.value = Params.TauxRetravail.toString();
    
    Params.LB_TransportRetravail = 3.00;
    LB_TransportRetravail.value = Params.LB_TransportRetravail.toString();
    
    Params.UB_TransportRetravail = 7.00;
    UB_TransportRetravail.value = Params.UB_TransportRetravail.toString();
    
    Params.ProbSortie = 0.75;
    ProbSortie.value = Params.ProbSortie.toString();
    
    Params.ProbDestruction = 0.20;
    ProbDestruction.value = Params.ProbDestruction.toString();
    
    Params.ProbRetravail = 0.05;
    ProbRetravail.value = Params.ProbRetravail.toString();
    
    //N LECTURE PARAMÈTRES
    
    
    ////////////////////////////////////////////////////////////////////////////
    
    //Éléments de simulation//
    
    
    //Bouton lancer 
    
    bouton_lancer.onClick.listen((Event e) { 
    
      
      
      Params.CombienReplications = int.parse(CombienReplications.value);
      Params.CombienEntites = int.parse(CombienEntites.value);
      Params.TauxArrivee =  double.parse(TauxArrivee.value) ;
      Params.TauxServeur1PremierPassage = double.parse(TauxServeur1PremierPassage.value);
      Params.TauxServeur2PremierPassage = double.parse(TauxServeur2PremierPassage.value);
      Params.TauxRetravail = double.parse(TauxRetravail.value);
      Params.LB_TransportRetravail = double.parse(LB_TransportRetravail.value);      
      Params.UB_TransportRetravail = double.parse(UB_TransportRetravail.value);
      Params.ProbSortie = double.parse(ProbSortie.value);
      Params.ProbDestruction = double.parse(ProbDestruction.value);
      Params.ProbRetravail = double.parse(ProbRetravail.value);


      var GenerateurVariablesAleatoires = new Random();
      var start = DateTime; //Dim start As DateTime = Now
    
    
      for (var REP = 1; REP < Params.CombienReplications+1; REP++) {     
      // La simulation se trouve dans cette boucle
      
      //À chaque réplication, il faut instancier un nouveau système (dans son état initial) avec des files vides et 2 serveurs neufs
      
      var Sys = new system();
      Sys.ReplicationNo = REP;
      Sys.file = new List<piece>();
      Sys.EntitesDetruites = new List<piece>();
      Sys.EntitesTraitees = new List<piece>();

      var MonServeur1 = new serveur();
      MonServeur1.No = 1;
      MonServeur1.PieceEnTraitement = null;
      Sys.serveur1 = MonServeur1;
      
      var MonServeur2 = new serveur();
      MonServeur2.No = 2;
      MonServeur2.PieceEnTraitement = null;
      Sys.serveur2 = MonServeur2;
      
      //Il faut aussi initialiser une horloge qui nous aide à gérer les événements
      double Horloge = 0.00;
      
      
      //Il faut aussi initialiser la liste d'événements et la liste d'événements traités
      Sys.ListEvenements = new List<Evenement>();
      Sys.EvenementsTraites = new List<Evenement>();

      
      //On va aussi créer la première arrivée, ce qui va déclencher le processus de simulation 
      //quand on va entrer dans la boucle ABC.J'utilise une fonction qui retourne une valeur
      //aléatoire de temps inter-arrivee selon une loi exponentielle de moyenne 1/taux. J'insère
      //ensuite cet événement dans ma liste d'événements non traites
      
      var MonPremierEvenement = new Evenement();
          MonPremierEvenement.Temps = generateExponential(Params.TauxArrivee, GenerateurVariablesAleatoires);     
          MonPremierEvenement.Libelle_Evenement = "AP";
          
          Sys.ListEvenements.add(MonPremierEvenement);
          
        
     //il faut finalement déclarer une variable de type booléen qui permet de déclencher 
     //la sortie de la boucle ABC lorsque la Nième pièce est traitée
          
      bool Termine = false; 
          

        ///////////////////////////////////////////////////////////////////////////
       ////////////////////          DÉBUT BOUCLE ABC          ///////////////////
      ///////////////////////////////////////////////////////////////////////////
      
      do {
        
        Evenement EvenementEnCours = Sys.ListEvenements.first;                                                                                     //ERREUR
               
        for (Evenement e in Sys.ListEvenements){
          if(e.Temps <= EvenementEnCours.Temps){
            EvenementEnCours = e;
          }
        }
        
                
       // PHASE A: Avancer l'horloge au prochain événement de la liste (celui ayant le temps d'occurence le plus faible). Commencer par récupérer l'événement.
       
        //Avancer l'horloge au temps de cet événement.
        Horloge = EvenementEnCours.Temps;

       //retirer l'événements de la liste des événements à traiter et l'ajouter à la liste des événements traités
        Sys.ListEvenements.remove(EvenementEnCours);
        Sys.EvenementsTraites.add(EvenementEnCours);
        
        
        //FIN PHASE A

       // Phase B
       // PHASE B: Changer l'état du système et créer, au besoin, les événements BOUND liés
        var pieceEnCours = new piece();
        
        if (EvenementEnCours.Libelle_Evenement == "AP"){
          var p = new piece();
          p.HeureArrivee = Horloge;
          Sys.file.add(p);
          
          //Générer l'arrivée de la pièce suivante
          var eve = new Evenement();
          eve.Temps = Horloge + generateExponential(Params.TauxArrivee, GenerateurVariablesAleatoires);                                                                                 //loi exponentiel au lier de 15
          eve.Libelle_Evenement = "AP";
          Sys.ListEvenements.add(eve);
          
          
         //FSP: L'événement en cours est une fin de service sur une pièce
          
        }else if (EvenementEnCours.Libelle_Evenement == "FSP"){
         //'commencer par récupérer la pièce qui a terminé le traitement
          
          piece pieceEnCours = null;
          if (EvenementEnCours.ServeurNo == 1){
            pieceEnCours = Sys.serveur1.PieceEnTraitement;
            Sys.serveur1.PieceEnTraitement = null;
             }else if (EvenementEnCours.ServeurNo == 2){
               pieceEnCours = Sys.serveur2.PieceEnTraitement;
               Sys.serveur2.PieceEnTraitement = null;
             }       
     

         double prob = GenerateurVariablesAleatoires.nextDouble();
         
          if (Params.ProbSortie >= prob ){
            //dans ce cas, le chemin est la sortie
            //marquer l'heure de sortie de la pièce
            pieceEnCours.HeureSortie = Horloge;
            pieceEnCours.FinTraitement = Horloge;
            //incrémenter le nombre de traitements de la pièce
            pieceEnCours.NbTraitements ++ ;
            //ajouter la piece à la liste des entités traitées
            Sys.EntitesTraitees.add(pieceEnCours);
            
          }else if ((Params.ProbSortie + Params.ProbDestruction) >= prob){
            //le chemin choisi est la destruction
            //Marquer l'heure de sortie de la pièce
            pieceEnCours.HeureSortie = Horloge;
            pieceEnCours.FinTraitement = Horloge;
            //incrémenter le nombre de traitements de la pièce
            pieceEnCours.NbTraitements ++ ;
            //ajouter la piece à la liste des entités détruites
            Sys.EntitesDetruites.add(pieceEnCours);
            
          }else if (Params.ProbDestruction + Params.ProbRetravail + Params.ProbSortie >= prob){
            //le chemin choisi est le retravail
            pieceEnCours.FinTraitement = Horloge;
            //créer l'événement retravail pièce à Horloge + temps de transport aléatoire
            pieceEnCours.NbTraitements ++ ;
            
            var eve = new Evenement();
            eve.Temps = Horloge + 3.00;                                                                                    //changer 3 pour loi uniforme
            eve.Libelle_Evenement = "RTP";
            eve.ServeurNo = 0;
            eve.PieceTransport = pieceEnCours;
            Sys.ListEvenements.add(eve);
            eve.NbrRTP ++ ;
            print(eve.NbrRTP);
          }
        
          //vérification de la condition de sortie à chaque fois qu'une unité est prête à sortir du serveur
          if ((Sys.EntitesTraitees.length + Sys.EntitesDetruites.length) == Params.CombienEntites){
            Termine = true;
            Sys.HeureDeFin = Horloge;
            }else if (EvenementEnCours.Libelle_Evenement == "RTP"){
              //L'événement en cours et une fin de transport vers la file pour une pièce à retravailler
              piece pieceEnCours = EvenementEnCours.PieceTransport;
              Sys.file.add(pieceEnCours);
            }
          
        }
       //   FIN PHASE B
          
       // PHASE C

         if (Termine != true ) {
           //Quelles sont les conditions qui font en sorte qu'un événement doit se déclencher ?
           //1) Serveur 1 libre et au moins une pièce en file - Déclencher un début de service sur le serveur 1
           if(Sys.serveur1.PieceEnTraitement == null && Sys.file.length> 0){                                            
        
             
            piece PieceEnCours = Sys.file.first;//récupérer la pièce de la file 
            Sys.file.remove(PieceEnCours);//On enlève la pièce de la file
            Sys.serveur1.PieceEnTraitement = PieceEnCours; //On affecte la pièce au seveur 1
            PieceEnCours.DebutTraitement = Horloge;//Marquer l'heure de début de service de l'entité
            PieceEnCours.ServeurTraitmement = 1;//MArquer le numéro de serveur traitant l'entité
            
            //Créer l'évènement Fin de Service Pièce "FSP" sur le serveur No 1 
            var eve = new Evenement();
            eve.Libelle_Evenement = "FSP";
            eve.ServeurNo = 1;
            //le temps d'exécution de l'événement dépend si c'est une pièce travaillée pour la première fois ou pas
            if (PieceEnCours.NbTraitements > 1){
              var tempsTraitement = generateExponential(Params.TauxRetravail, GenerateurVariablesAleatoires);                                                           //remplacer par GenerateExponential(Params.TauxRetravail,GenerateurVariablesAleatoires)
              eve.Temps = Horloge + tempsTraitement;
              Sys.serveur1.SommeTempsOccupe = Sys.serveur1.SommeTempsOccupe + tempsTraitement;
            
            }else{
              var tempsTraitement = generateExponential(Params.TauxServeur1PremierPassage, GenerateurVariablesAleatoires);                                                           //remplacer par GenerateExponential(Params.TauxRetravail,GenerateurVariablesAleatoires)
              eve.Temps = Horloge + tempsTraitement;
              Sys.serveur1.SommeTempsOccupe = Sys.serveur1.SommeTempsOccupe + tempsTraitement; 
                          
            }
            Sys.ListEvenements.add(eve);
           }
           
      // 2) Serveur 2 libre et au moins une pièce en file - Déclencher un début de service sur le serveur 2 
           if(Sys.serveur2.PieceEnTraitement == null && Sys.file.length> 0){
             piece PieceEnCours = Sys.file.first;
             Sys.serveur2.PieceEnTraitement = PieceEnCours;
             PieceEnCours.DebutTraitement = Horloge;
             PieceEnCours.ServeurTraitmement = 2;
             //créer l'événement fin de service
             var eve = new Evenement();
             eve.Libelle_Evenement = "FSP";
             eve.ServeurNo = 2;
             //le temps d'exécution de l'événement dépend si c'est une pièce travaillée pour la première fois ou pas   
             if (PieceEnCours.NbTraitements > 1){
               var tempsTraitement = generateExponential(Params.TauxRetravail, GenerateurVariablesAleatoires);
               eve.Temps = Horloge + tempsTraitement;
               Sys.serveur2.SommeTempsOccupe += tempsTraitement;
               
             }else{
               var tempsTraitement =  generateExponential(Params.TauxServeur2PremierPassage, GenerateurVariablesAleatoires);                                                           
               eve.Temps = Horloge + tempsTraitement;
               Sys.serveur2.SommeTempsOccupe += tempsTraitement;
               
             }
             //Ajouter l'événement à la liste des événements à traiter
             Sys.ListEvenements.add(eve);
           }
           //FIN PHASE C
         }
                  
        } while (!Termine); //fin boucle des réplications
      
      //ajouter l'objet sys contenant les listes d'entités traitées à l'objet params qui mémorise les paramètres et les résultats pour l'ensemble des réplications  
      Params.Resultats.add(Sys);
      

    }
    
    
    
    //////////////////////////////////////////  //////////////////////////////////////////  //////////////////////////////////////////  
    //////////////////////////////////////////          Résultats de la simulation          //////////////////////////////////////////  
    //////////////////////////////////////////  //////////////////////////////////////////  //////////////////////////////////////////  

    //Calcul des statistiques de simulation (N réplication)
    
    //calculer les stats pour chaque réplication selon ce qui est demandé
    //alors nous bouclons pour chaque réplication

    double HeureDeFinMoyennes = 0.00;
    double CombienSortiesMoyennes = 0.00;
    double CombienDetruitesMoyennes = 0.00;
    double CombienPlusieursTraitementsMoyennes = 0.00;
    double TauxOccS1Moyen = 0.00;
    double TauxOccS2Moyen = 0.00;

    for (int i = 1; i< Params.CombienReplications+1; i++){
      
      //Quelle heure est-il à la fin de la Nieme unité traitée
      double heureFin = Params.Resultats.elementAt(i-1).HeureDeFin;
      HeureDeFinMoyennes += heureFin;
      //Combien d'entités sont sorties (sans destruction mais retravail inclus) 
      int CombienSorties = Params.Resultats.elementAt(i-1).EntitesTraitees.length;
      CombienSortiesMoyennes += CombienSorties;
      //combien d'entités sont détruites
      int CombienDetruites = Params.Resultats.elementAt(i-1).EntitesDetruites.length;
      CombienDetruitesMoyennes += CombienDetruites;
      //Combien d'entités sont traitées plus d'une fois (retravaillée) parmi les entités traitées et les entités détruites 
      int CombienPlusieursTraitements=0;
      
      for (piece p in Params.Resultats.elementAt(i-1).EntitesTraitees){
        if (p.NbTraitements>1){
          CombienPlusieursTraitements ++;
        }
        
      }
      
      for (piece p in Params.Resultats.elementAt(i-1).EntitesDetruites){
        if (p.NbTraitements>1){
          CombienPlusieursTraitements ++;
        }
        
      }
      CombienPlusieursTraitementsMoyennes += CombienPlusieursTraitements;
    // Combien de temps (proportion) le serveur 1 est-il occupé ?
      double proportionServeur1Occupe = Params.Resultats.elementAt(i-1).serveur1.SommeTempsOccupe / heureFin;
      TauxOccS1Moyen += proportionServeur1Occupe;
      
    //Combien de temps (proportion) le serveur 2 est-il occupé ?
      double proportionServeur2Occupe = Params.Resultats.elementAt(i-1).serveur2.SommeTempsOccupe / heureFin;
      TauxOccS2Moyen += proportionServeur2Occupe;
    }  
    
    HeureDeFinMoyennes = HeureDeFinMoyennes / Params.CombienReplications;
    CombienSortiesMoyennes /= Params.CombienReplications;
    CombienDetruitesMoyennes /= Params.CombienReplications;
    CombienPlusieursTraitementsMoyennes /= Params.CombienReplications;
    TauxOccS1Moyen /= Params.CombienReplications;
    TauxOccS2Moyen /= Params.CombienReplications;
    
    input1.value = 'Durée moyenne de traitement en heures : '+(HeureDeFinMoyennes/60).toString();
    input2.value = 'Nombre moyen de pièces complétées : ' + (CombienSortiesMoyennes).toString();
    input3.value = 'Nombre moyen de pièces détruites : ' + (CombienDetruitesMoyennes).toString();
    input4.value = 'Nombre moyen de pièces retravaillées : '+(CombienPlusieursTraitementsMoyennes).toString();
    input5.value = "Taux d'occupation moyen du serveur No 1 : " + (TauxOccS1Moyen).toString();
    input6.value = "Taux d'occupation moyen du serveur No 2 " + (TauxOccS2Moyen).toString();    
    
});  
}



double generateExponential (double taux, Random generator) { 
  double valeur = (-1/taux) * log(generator.nextDouble()) * 60; 
  return valeur; 
  }

double generateUniform (double LB,double UB, Random generator){ 
  double valeur; if (LB < UB) { 
    valeur = ((UB - LB) * generator.nextDouble()) + LB;
    } 
  return valeur; 
  }


bind_elements() {
    
    var i =1;
    
    CombienReplications = querySelector('#CombienReplications');
    CombienEntites = querySelector('#CombienEntites');
    TauxArrivee = querySelector('#TauxArrivee');
    TauxServeur1PremierPassage = querySelector('#TauxServeur1PremierPassage');
    TauxServeur2PremierPassage = querySelector('#TauxServeur2PremierPassage');
    TauxRetravail = querySelector('#TauxRetravail');
    LB_TransportRetravail = querySelector('#LB_TransportRetravail');
    UB_TransportRetravail = querySelector('#UB_TransportRetravail');
    ProbSortie = querySelector('#ProbSortie');
    ProbDestruction = querySelector('#ProbDestruction');
    ProbRetravail = querySelector('#ProbRetravail');
    bouton_lancer = querySelector('#bouton_lancer');
    
  
    input1 = querySelector('#input1');
    input2 = querySelector('#input2');
    input3 = querySelector('#input3');
    input4 = querySelector('#input4');
    input5 = querySelector('#input5');
    input6 = querySelector('#input6');
    
    
} 
