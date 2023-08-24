import noiseTool.utils as utils


def test_is_number_cool_positive():
    assert utils.is_number_cool(42)


def test_is_number_cool_negative():
    assert not utils.is_number_cool(30)
