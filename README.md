# EA_HedgePositions

## Description
This is a money management semi-automated investment strategy designed to manage the risk on your positions

## How it works
You have to do your own market analysis to determine whether the price of your preferred asset will go up or down.
Then, you set up the EA's parameters based on your analysis and the pair you are trading.
Finally, you just have to wait. You can sleep or do whatever you want, as the EA will manage the trades based on your analysis until it reaches your take profit.

## EA's logic
Our goal is to reduce drawdown as much as possible while we wait for the price to touch our target. 
If your analysis is wrong, you will lose. But in any case, this EA is expected to reduce your drawdown and improve your profit factor.
The EA doesn't setup visible stop loss and take profit, but that doesn't mean that we are exposed to a lot of risk as the EA will close both losing positions (and try to open it again later at a better price) and winning positions with risk of retracing. So, you are always protected in the same way as if you were using a stop loss.

EA will be using candles patterns as well as trailing price colliders to determine if it's time to open or close a position. 
Candle patterns example:
<p align="left">
  <img src="Screenshots/spike_candle.PNG" width="1000" title="Candles">  
  <img src="Screenshots/reversal_candle.PNG" width="1000" title="Candles"> 
  <img src="Screenshots/morning_star.PNG" width="1000" title="Candles"> 
</p>

