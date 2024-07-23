import logging, pytest, cocotb
from random import randint
from cocotb.triggers import Timer

from mase_cocotb.runner import mase_runner

WIDTH = 8
SHIFT = 5

logger = logging.getLogger('testbench')
logger.setLevel(logging.INFO)

def led_switch_sw(switches:list) -> list:
    """ Returns the corresponding LED to be turned on. """
    
    assert len(switches) == WIDTH, \
        'length of list switch_indexes does not match param WIDTH'
    
    rets = [0,0,0,0,0,0,0,0]
    for i in range(len(switches)):
        ret_index = 0
        ret_index = i - SHIFT
        ret_index = ret_index + WIDTH if ret_index < 0 else ret_index
        rets[ret_index] = switches[i]
    return rets

def list_to_bits(lst:list) -> int:
    """ Converts e.g. [0,1,1,0,1] to 0b01101. """

    ret:int = 0
    for i in range(len(lst)):
        ret += 2**(WIDTH - 1 - i) * lst[i]
    return ret

@cocotb.test()
async def cocotb_test_led_switch(dut):
    """ Randomly switch on switches in sequence, test the result. """

    for test_i in range(30):
        switch_indexes = [randint(0, 1) for i in range(WIDTH)]
        
        dut.switches.value = list_to_bits(switch_indexes)

        await Timer(10, units='ns')

        result = list_to_bits(led_switch_sw(switch_indexes))

        assert dut.leds.value == result, \
            'Randomized test failed with switches = {}, leds = {}, expect: {}'.format(
                hex(int(dut.switches.value)), hex(int(dut.leds.value)), hex(result)
            )


@pytest.mark.dev
def test_led_switch():
    mase_runner()

if __name__ == '__main__':
    test_led_switch()
