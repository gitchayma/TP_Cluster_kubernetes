# TP_Final

1. Configure the AWS Provider
2. Création de l'infrastructure sur terraform:

    a/ Création du VPC (Virtual Private Cloud) : 
        servira de base de notre cluster kubernetes

    b/ Création de Sous-Réseaux :
        Creer:
        * un seul subnet (Sous-réseau)
        NB: Les sous-réseaux publics sont généralement utilisés pour les nœuds maîtres Kubernetes. 
            les sous-réseaux privés sont destinés aux nœuds de travail (workers). 
            Cela permet de séparer les nœuds qui sont accessibles depuis Internet de ceux qui ne le sont pas.

    c/ gérer le trafic entre les nœuds (Nodes) Kubernetes et d'autres ressources AWS ou Internet:
        # crée gateway: mettre à disposition des instances une connéctivité internet
        # crée Route table:  configurer une table de routage pour diriger le trafic Internet
        # Associé route table à Subnet

    d/ Création de Groupes de Sécurité: définire les règles de pare-feu
        creer une clé ssh

    e/ Création d'Instances EC2 :   
        Kubernetes Controllers: 1
        Kubernetes Workers: 2

3. provisionner et configurer les instances EC2 en tant que nœuds Kubernetes sur ansible

