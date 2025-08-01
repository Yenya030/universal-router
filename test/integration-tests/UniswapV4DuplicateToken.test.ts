import { expect } from './shared/expect'
import hre from 'hardhat'
import { BigNumber } from 'ethers'
import { expandTo18DecimalsBN } from './shared/helpers'
import { resetFork, PERMIT2 } from './shared/mainnetForkHelpers'
import { deployV4PoolManager, addLiquidityToV4Pool, USDC_WETH } from './shared/v4Helpers'
import deployUniversalRouter from './shared/deployUniversalRouter'
import { Actions, V4Planner } from './shared/v4Planner'
import { CommandType, RoutePlanner } from './shared/planner'
import { executeRouter } from './shared/executeRouter'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { FeeAmount, ADDRESS_ZERO } from '@uniswap/v3-sdk'
const { ethers } = hre

// Attempt to swap using a path where currency0 and currency1 are identical

describe('V4 Duplicate Token Path', () => {
  let bob: SignerWithAddress
  let router: any
  let wethContract: any
  let usdcContract: any
  let planner: RoutePlanner
  let v4Planner: V4Planner
  let v4PoolManager: any

  const amountInNative: BigNumber = expandTo18DecimalsBN(1)

  beforeEach(async () => {
    ;[bob] = await ethers.getSigners()
    await resetFork()
    v4PoolManager = await deployV4PoolManager(bob.address)
    ;({ router, wethContract, usdcContract } = await deployUniversalRouter(PERMIT2.address, v4PoolManager.address))
    await addLiquidityToV4Pool(v4PoolManager, USDC_WETH, expandTo18DecimalsBN(2).toString(), bob)
    planner = new RoutePlanner()
    v4Planner = new V4Planner()
  })

  it('reverts for duplicate token pool key', async () => {
    const currencyIn = wethContract.address
    const invalidPoolKey = {
      currency0: wethContract.address,
      currency1: wethContract.address,
      fee: FeeAmount.LOW,
      tickSpacing: 10,
      hooks: ADDRESS_ZERO,
    }
    v4Planner.addAction(Actions.SWAP_EXACT_IN, [
      {
        currencyIn,
        path: [invalidPoolKey],
        amountIn: amountInNative,
        amountOutMinimum: 0,
      },
    ])
    v4Planner.addAction(Actions.SETTLE_ALL, [currencyIn, ethers.constants.MaxUint256])
    v4Planner.addAction(Actions.TAKE_ALL, [currencyIn, 0])

    planner.addCommand(CommandType.V4_SWAP, [v4Planner.actions, v4Planner.params])

    await expect(
      executeRouter(planner, bob, router, wethContract, usdcContract, usdcContract)
    ).to.be.reverted
  })
})
