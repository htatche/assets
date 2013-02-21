Feature: Disposem de un modul de usuaris on la gent es pot identificar.

Scenario: Iniciar sessio
#Given Visitem la pagina de login do 
When 'cocozz@gmail.com' inicie sessio
Then Tindria que veure la home de la empresa
