//+------------------------------------------------------------------+
//|                                               HedgePositions.mq4 |
//|                                           Copyright 2019, Pablo. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Pablo."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

//Includes
#include <states.mqh>
#include <entryInterest.mqh>
#include <trailingPrice.mqh>
#include <getLowMax.mqh>

//Variables
input int magic = 17;
input double lots = 0.01;
input double SL = 20;
input double TP = 1.2;
input double startPrice = 1.14;

bool oportunity = true;
int slippage = 10;

//state = Hedge
input double hedgeDistance = 500; //distance in points (not pips) from the low to SL - Entry point for hedge
input double reOpenDistance = 500;
double reOpenPrice = 0; //Price at which we will re-enter the market


int OnInit()
  {
   return(INIT_SUCCEEDED);
  }
void OnDeinit(const int reason)
  {
  }
void OnTick()
  {
   if(iHigh(NULL,PERIOD_W1,0) >= TP)
   {
      //Price touched TP, so we stop operating that pair
      oportunity = false;
   }
   
   reOpenPrice = trailingPrice("down",reOpenPrice,reOpenDistance);
   
   
   if(buyInterest() == true || Ask == reOpenPrice)
   {
      int buy = OrderSend(Symbol(),OP_BUY,0.01,Ask,10,NULL,NULL,NULL,magic,0,clrGreen);
      reOpenPrice = Ask - hedgeDistance;
   }else if(sellInterest() == true)
   {
      int sell = OrderSend(Symbol(),OP_SELL,0.01,Bid,10,NULL,NULL,NULL,magic,0,clrRed);
   }  
  }  


bool CheckHedge(int cmd, int entryDistance)
{  //We check that price exists to open a hedge position
   if(cmd == OP_SELLSTOP)
   {
      return true;
   }else if(cmd == OP_BUYSTOP)
   {
      return true;
   }
   return true;
}

int MarketOrderSend(string symbol, int cmd, double volume, double price, int slipagge, double stoploss, double takeprofit, string comment)
{
   int newOrder;
   
   newOrder = OrderSend(symbol, cmd, volume, price, slippage, stoploss, takeprofit, NULL, magic);
   if(newOrder <= 0)Alert("OrderSend Error: ", GetLastError());
   
   return(newOrder);
}