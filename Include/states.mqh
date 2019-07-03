//+------------------------------------------------------------------+
//|                                                       states.mqh |
//|                                           Copyright 2019, Pablo. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Pablo."
#property link      "https://www.mql5.com"
#property strict

enum States
{
   Wait, //Wait for a better price before entering the market
   Start, //Make the first trade and start operating
   OpenHedge, //Hedge the position if it goes agains us
   CloseHedge, //Closes the hedge to enter the market again
   Finish //Send an email to me to turn off the EA in that specific pair and find a new pair
};

States state;