import { expect } from './shared/expect'
import hre from 'hardhat'
import { resetFork, PERMIT2, WETH } from './shared/mainnetForkHelpers'
import { deployV4PoolManager } from './shared/v4Helpers'
import deployUniversalRouter from './shared/deployUniversalRouter'
import { CommandType, RoutePlanner } from './shared/planner'
import { DEADLINE } from './shared/constants'
import { ADDRESS_ZERO, FeeAmount } from '@uniswap/v3-sdk'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
const { ethers } = hre

describe('V4 Invalid Pool Initialization', () => {
  let bob: SignerWithAddress
  let router: any
  let wethContract: any
  let planner: RoutePlanner
  let v4PoolManager: any

  beforeEach(async () => {
    ;[bob] = await ethers.getSigners()
    await resetFork()
    v4PoolManager = await deployV4PoolManager(bob.address)
    ;({ router, wethContract } = await deployUniversalRouter(PERMIT2.address, v4PoolManager.address))
    planner = new RoutePlanner()
  })

  it('reverts when initializing a pool with identical tokens', async () => {
    const invalidPoolKey = {
      currency0: wethContract.address,
      currency1: wethContract.address,
      fee: FeeAmount.LOW,
      tickSpacing: 10,
      hooks: ADDRESS_ZERO,
    }

    planner.addCommand(CommandType.V4_INITIALIZE_POOL, [invalidPoolKey, 1])
    const { commands, inputs } = planner
    await expect(
      router.connect(bob)['execute(bytes,bytes[],uint256)'](commands, inputs, DEADLINE)
    ).to.be.reverted
  })
})
