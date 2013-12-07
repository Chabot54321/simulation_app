
library Classes;
  import "dart:math";

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
  double Temps;                                                                                                     //différent du code (a valider)
  String Libelle_Evenement ;
  int ServeurNo ;
  piece PieceTransport ;
}

class system {
  int ReplicationNo ;
  List<Evenement> ListEvenements;                                                                                   //voir s'il faut NEW LIST
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
  var Params = new SimulationDatas() ;        //Pas sur de la traduction
    
  Params.Resultats = new List<system>();    //Pas sur de la traduction
  
    Params.CombienReplications = 50;
    
    Params.CombienEntites = 250 ;
    
    Params.TauxArrivee = 15.00;
    
    Params.TauxServeur1PremierPassage = 12.00;
    
    Params.TauxServeur2PremierPassage = 12.00;
    
    Params.TauxRetravail = 12.00;
    
    Params.LB_TransportRetravail = 3.00;
    
    Params.UB_TransportRetravail = 7.00;
   
    Params.ProbSortie = 0.75;
    
    Params.ProbDestruction = 0.08;
    
    Params.ProbRetravail = 0.2;
    
    //N LECTURE PARAMÈTRES
    
    
    ////////////////////////////////////////////////////////////////////////////
    
    //Éléments de simulation
    
    var GenerateurVariablesAleatoires = new Random();
    var start = DateTime; //Dim start As DateTime = Now
    
    
    for (var REP = 1; REP < Params.CombienReplications; REP++) {
     
      
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
          MonPremierEvenement.Temps = 1.00;            // tentative sans nombre aléatoire remplacer 1 par loi exponentiel
          MonPremierEvenement.Libelle_Evenement = "AP";
          Sys.ListEvenements.add(MonPremierEvenement);
     
     //il faut finalement déclarer une variable de type booléen qui permet de déclencher 
     //la sortie de la boucle ABC lorsque la Nième pièce est traitée
          
      bool Termine; 
          

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
          
          var eve = new Evenement();
          eve.Temps = Horloge + 15.00;                                                                                 //loi exponentiel au lier de 15
          eve.Libelle_Evenement = "AP";
          Sys.ListEvenements.add(eve);
          
          
         //FSP
          
        }else if (EvenementEnCours.Libelle_Evenement == "FSP"){
                     
          piece pieceEnCours = null;
          if (EvenementEnCours.ServeurNo == 1){
            pieceEnCours = Sys.serveur1.PieceEnTraitement;
            Sys.serveur1.PieceEnTraitement = null;
             }else if (EvenementEnCours.ServeurNo == 2){
               pieceEnCours = Sys.serveur2.PieceEnTraitement;
               Sys.serveur2.PieceEnTraitement = null;
             }       
        ////
        ////
        ////
        var prob =  0.60;
          if (Params.ProbSortie >= prob ){
            pieceEnCours.HeureSortie = Horloge;
            pieceEnCours.FinTraitement = Horloge;
            
            pieceEnCours.NbTraitements ++ ;
            
            Sys.EntitesTraitees.add(pieceEnCours);
            
          }else if ((Params.ProbSortie + Params.ProbDestruction) >= prob){
            pieceEnCours.HeureSortie = Horloge;
            pieceEnCours.FinTraitement = Horloge;
            pieceEnCours.NbTraitements ++ ;
            Sys.EntitesDetruites.add(pieceEnCours);
            
          }else if (Params.ProbDestruction + Params.ProbRetravail + Params.ProbSortie){
            pieceEnCours.FinTraitement = Horloge;
            pieceEnCours.NbTraitements ++ ;
            
            var eve = new Evenement();
            eve.Temps = Horloge + 3.00;                                                                                    //changer 3 pour loi uniforme
            eve.Libelle_Evenement = "RTP";
            eve.ServeurNo = 0;
            eve.PieceTransport = pieceEnCours;
            Sys.ListEvenements.add(eve);
          }
        
 
          if ((Sys.EntitesTraitees.length + Sys.EntitesDetruites.length) == Params.CombienEntites){
            Termine = true;
            Sys.HeureDeFin = Horloge;
            }else if (EvenementEnCours.Libelle_Evenement == "RTP"){
              piece pieceEnCours = EvenementEnCours.PieceTransport;
              Sys.file.add(pieceEnCours);
            }
          
        }
       //   FIN PHASE B

          
       // PHASE C

         if (Termine != true ) {
           //Quelles sont les conditions qui font en sorte qu'un événement doit se déclencher ?
           //1) Serveur 1 libre et au moins une pièce en file - Déclencher un début de service sur le serveur 1
           if(Sys.serveur1.PieceEnTraitement == null && Sys.file.length> 0){                                            //A valider
         //If Sys.Serveur1.PieceEnTraitement Is Nothing And Sys.file.Count > 0 Then  
             
            piece PieceEnCours = Sys.file.first;
            Sys.file.remove(PieceEnCours);
            Sys.serveur1.PieceEnTraitement = PieceEnCours;
            PieceEnCours.DebutTraitement = Horloge;
            PieceEnCours.ServeurTraitmement = 1;
            
            var eve = new Evenement();
            eve.Libelle_Evenement = "FSP";
            eve.ServeurNo = 1;
            
            if (PieceEnCours.NbTraitements > 1){
              var tempsTraitement = 15.00;                                                           //remplacer par GenerateExponential(Params.TauxRetravail,GenerateurVariablesAleatoires)
              eve.Temps = Horloge + tempsTraitement;
              Sys.serveur1.SommeTempsOccupe += tempsTraitement;
            
            }else{
              var tempsTraitement = 15.00;                                                           //remplacer par GenerateExponential(Params.TauxRetravail,GenerateurVariablesAleatoires)
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
             
             var eve = new Evenement();
             eve.Libelle_Evenement = "FSP";
             eve.ServeurNo = 2;
      //le temps d'exécution de l'événement dépend si c'est une pièce travaillée pour la première fois ou pas   
             if (PieceEnCours.NbTraitements > 1){
               var tempsTraitement = 15;                                                           //remplacer par GenerateExponential(Params.TauxRetravail,GenerateurVariablesAleatoires)
               eve.Temps = Horloge + tempsTraitement;
               Sys.serveur2.SommeTempsOccupe += tempsTraitement;
               
             }else{
               var tempsTraitement = 15;                                                           //remplacer par GenerateExponential(Params.TauxRetravail,GenerateurVariablesAleatoires)
               eve.Temps = Horloge + tempsTraitement;
               Sys.serveur2.SommeTempsOccupe += tempsTraitement;
               
             }
             Sys.ListEvenements.add(eve);
           }
           //FIN PHASE C
         }
          
           
        
        } while (Termine = true); //fin du DO
        
      Params.Resultats.add(Sys);                                                                              //Il faut recommencer la boucle des REP;


    }
    
}

double generateExponential (double taux, Random generator) { 
  double valeur = (-1/taux) * log(generator.nextDouble()); 
  return valeur; 
  }

double generateUniform (double LB,double UB, Random generator){ 
  double valeur; if (LB < UB) { 
    valeur = ((UB - LB) * generator.nextDouble()) + LB;
    } 
  return valeur; }
