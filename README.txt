Alef is an open-finance application that elects and rewards competent students who wish to learn blockchain and open-source programming with scholarship opportunities. The funds will be provided by sponsors who are willing to lock their money into a savings account for a certain period of time and pay off the tuition fees with the generated interest so that sponsors’ money will be fully refunded once that period passes.

Alef also has a unique way of selecting the students who are most worthy of the funds, it is called Quadrating Funding (QF). QF is a voting mechanism that determines the amount of financial help each student will get. It lets the community that is backing a certain open-source project vote over which student is going to be of benefit to them and ensures that the rewarded students are likely to be hired and contribute in building these projects once they graduate. 

This app will be tested on the Ivan on Tech academy because they offer a wide range of affordable and high quality blockchain and programming online courses with more than fifteen thousand active students and a community of more than a hundred thousand subscribers on YouTube. (More academies and online institutions can be added in the future)

Participants:
• Academy(s): Ivan on Tech Academy teaching high-quality blockchain and programming courses.
• Students: Competent individuals who are eager to learn and develop in an ecosystem applying for scholarships.
• Ecosystems: Companies, foundations, and exchanges providing the bulk of the funds in order to onboard talented developers.
• Contributors: Crypto communities selecting the best available talent to build the ecosystem.

Running under the hood is the Compound protocol which offers its lenders 2-7.5% of annual interest on their deposits. To understand where this interest is coming from it’s important to mention that on the other side of this network there are borrowers who are willing to take out these loans and pay them back with interest at each produced Ethereum block. The interest that borrowers pay produces the interest that lenders earn.

When a lender locks tokens such as Dai, Compound mints and transfers cDai tokens to her wallet. The increase in the exchange rate between Dai and cDai determines the interest rate earnings. Alef calculates the amount of money sponsors have to lock into Compound (The principal) in order to generate enough interest to cover the monthly tuition fees of students using this formula:

                             Principal = Monthly tuition fees / Interest rate
                             

However this formula assumes a constant interest rate which means that if it decreases, it will delay the monthly tuition fees by a small period of time and vice versa. The contract will trigger a withdrawal function from Compound whenever the Dai/cDai exchange rate reaches a certain number. As seen in the example above, if 

                             TuitionFees = (cDaiBalance * ExchangeRate) - Principle
then, 
                             ExchangeRate = (TuitionFees + Principle) / cDaiBalance


• Once an offer is accepted by the sponsor, the funds will be transferred from his balance to Compound. //In the future, sponsors could raise funds by joining pools and fulfilling academies’ offers collectively using quadratic funding
• Interest in Compound is generated in real-time and transferred to an academy’s address once it equates to a one-month tuition fees.
• Sponsors can also choose to redeem their cDai and withdraw their balance at any time.

Quadratic Funding will be added in the future. QF is a voting mechanism that determines the amount of financial help each student will get. It lets the community that is backing a certain open-source project vote over which student is going to be of benefit to them and ensures that the rewarded students are likely to be hired and contribute in building these projects once they graduate. 

    
    ------This project is developed by Ivan on Tech Academy buidlers------
    
    Whitepaper > https://docs.google.com/document/d/1RrP8wNxnfs_7iIQf6IGkdgOm4I8kgEACPDV9w8PO5mI/edit?usp=sharing
    Join our discord > https://discordapp.com/invite/n7ZCkM
    Register in our Blockchain academy > https://academy.ivanontech.com/a/17936/fKsHrhAs
    
    
    
    
    
