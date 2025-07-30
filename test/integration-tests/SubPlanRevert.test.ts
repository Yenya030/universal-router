import { CommandType, RoutePlanner } from './shared/planner'
import { expect } from './shared/expect'
import { UniversalRouter } from '../../typechain'
import { resetFork, USDC } from './shared/mainnetForkHelpers'
import { ALICE_ADDRESS, DEADLINE } from './shared/constants'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import hre from 'hardhat'
import deployUniversalRouter from './shared/deployUniversalRouter'
import { BigNumber, Contract } from 'ethers'
import { abi as TOKEN_ABI } from '../../artifacts/solmate/src/tokens/ERC20.sol/ERC20.json'
const { ethers } = hre

describe('Execute Sub Plan', () => {
  let alice: SignerWithAddress
  let router: UniversalRouter
  let planner: RoutePlanner
  let usdcContract: Contract
  let aliceUSDCBalance: BigNumber

  beforeEach(async () => {
    await resetFork()
    await hre.network.provider.request({
      method: 'hardhat_impersonateAccount',
      params: [ALICE_ADDRESS],
    })
    alice = await ethers.getSigner(ALICE_ADDRESS)
    router = (await deployUniversalRouter(alice.address)).connect(alice) as UniversalRouter
    usdcContract = new ethers.Contract(USDC.address, TOKEN_ABI, alice)
    aliceUSDCBalance = await usdcContract.balanceOf(ALICE_ADDRESS)
    planner = new RoutePlanner()
  })

  it('continues when sub plan fails and allowRevert is set', async () => {
    const sub = new RoutePlanner()
    const invalidBalance = aliceUSDCBalance.add(1)
    sub.addCommand(CommandType.BALANCE_CHECK_ERC20, [ALICE_ADDRESS, USDC.address, invalidBalance])
    planner.addSubPlan(sub)
    planner.addCommand(CommandType.BALANCE_CHECK_ERC20, [ALICE_ADDRESS, USDC.address, aliceUSDCBalance])
    const { commands, inputs } = planner
    await expect(router['execute(bytes,bytes[],uint256)'](commands, inputs, DEADLINE)).to.not.be.reverted
  })
})
