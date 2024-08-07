# mase_op : the set of functional equivalent IPs with different design configurations.
# The first IP in each list is used by default
norm = {
    "name": "norm",
    "dependence_files": [
        "common/rtl/join2.sv",
        "common/rtl/split2.sv",
        "common/rtl/repeat_circular_buffer.sv",
        "common/rtl/skid_buffer.sv",
        "common/rtl/register_slice.sv",
        "common/rtl/simple_dual_port_ram.sv",
        "common/rtl/fifo.sv",
        "common/rtl/lut.sv",
        "cast/rtl/floor_round.sv",
        "cast/rtl/signed_clamp.sv",
        "cast/rtl/fixed_signed_cast.sv",
        "fixed_arithmetic/rtl/fixed_accumulator.sv",
        "fixed_arithmetic/rtl/fixed_adder_tree.sv",
        "fixed_arithmetic/rtl/fixed_adder_tree_layer.sv",
        "fixed_arithmetic/rtl/fixed_lut_index.sv",
        "fixed_math/rtl/fixed_nr_stage.sv",
        "fixed_arithmetic/rtl/fixed_range_augmentation.sv",
        "fixed_arithmetic/rtl/fixed_range_reduction.sv",
        "fixed_math/rtl/fixed_isqrt.sv",
        "matmul/rtl/matrix_fifo.sv",
        "matmul/rtl/matrix_flatten.sv",
        "matmul/rtl/matrix_unflatten.sv",
        "norm/rtl/channel_selection.sv",
        "norm/rtl/group_norm_2d.sv",
        "norm/rtl/rms_norm_2d.sv",
        "norm/rtl/batch_norm_2d.sv",
        "norm/rtl/norm.sv",
    ],
}

INTERNAL_COMP = {
    "linear": [
        {
            "name": "fixed_linear",
            "dependence_files": [
                "cast/rtl/fixed_cast.sv",
                "fixed_arithmetic/rtl/fixed_dot_product.sv",
                "fixed_arithmetic/rtl/fixed_vector_mult.sv",
                "fixed_arithmetic/rtl/fixed_accumulator.sv",
                "fixed_arithmetic/rtl/fixed_adder_tree.sv",
                "fixed_arithmetic/rtl/fixed_adder_tree_layer.sv",
                "fixed_arithmetic/rtl/fixed_mult.sv",
                "common/rtl/unpacked_repeat_circular_buffer.sv",
                "common/rtl/register_slice.sv",
                "common/rtl/join2.sv",
                "common/rtl/skid_buffer.sv",
                "linear/rtl/fixed_linear.sv",
            ],
        },
    ],
    "relu": [
        {
            "name": "fixed_relu",
            "dependence_files": [
                "activations/rtl/fixed_relu.sv",
            ],
        },
    ],
    "hardshrink": [
        {
            "name": "fixed_hardshrink",
            "dependence_files": [
                "activations/rtl/fixed_hardshrink.sv",
            ],
        },
    ],
    "silu": [
        {
            "name": "fixed_silu",
            "dependence_files": [
                "activations/rtl/fixed_silu.sv",
                "activations/rtl/silu_lut.sv",
            ],
        },
    ],
    "elu": [
        {
            "name": "fixed_elu",
            "dependence_files": [
                "activations/rtl/fixed_elu.sv",
                "activations/rtl/elu_lut.sv",
            ],
        },
    ],
    "sigmoid": [
        {
            "name": "fixed_sigmoid",
            "dependence_files": [
                "activations/rtl/fixed_sigmoid.sv",
                "activations/rtl/sigmoid_lut.sv",
            ],
        },
    ],
    "softshrink": [
        {
            "name": "fixed_softshrink",
            "dependence_files": [
                "activations/rtl/fixed_softshrink.sv",
            ],
        },
    ],
    "logsigmoid": [
        {
            "name": "fixed_logsigmoid",
            "dependence_files": [
                "activations/rtl/fixed_logsigmoid.sv",
                "activations/rtl/logsigmoid_lut.sv",
            ],
        },
    ],
    "softmax": [
        {
            "name": "fixed_softmax",
            "dependence_files": [
                "activations/rtl/fixed_softmax.sv",
                "activations/rtl/exp_lut .sv",
            ],
        }
    ],
    "batch_norm2d": [norm],
    "layer_norm": [norm],
    "group_norm": [norm],
    "instance_norm2d": [norm],
    "rms_norm": [norm],
    "selu": [
        {
            "name": "fixed_selu",
            "dependence_files": [
                "activations/rtl/fixed_selu.sv",
            ],
        },
    ],
    "tanh": [
        {
            "name": "fixed_tanh",
            "dependence_files": [
                "activations/rtl/fixed_tanh.sv",
            ],
        },
    ],
    "gelu": [
        {
            "name": "fixed_gelu",
            "dependence_files": [
                "activations/rtl/fixed_gelu.sv",
                "activations/rtl/gelu_lut.sv",
            ],
        },
    ],
    "softsign": [
        {
            "name": "fixed_softsign",
            "dependence_files": [
                "activations/rtl/fixed_softsign.sv",
                "fixed_arithmetic/rtl/fixed_mult.sv",
            ],
        },
    ],
    "softplus": [
        {
            "name": "fixed_softplus",
            "dependence_files": [
                "activations/rtl/fixed_softplus.sv",
            ],
        },
    ],
    "add": [
        {
            "name": "fixed_adder",
            "dependence_files": [
                "fixed_arithmetic/rtl/fixed_adder.sv",
            ],
        }
    ],
    "mul": [
        {
            "name": "fixed_elementwise_multiplier",
            "dependence_files": [
                "fixed_arithmetic/rtl/fixed_elementwise_multiplier.sv",
            ],
        }
    ],
    "df_split": [
        {
            "name": "df_split",
            "dependence_files": ["common/rtl/df_split.sv", "common/rtl/split2.sv"],
        }
    ],
    "getitem": [
        {
            "name": "buffer",
            "dependence_files": [
                "common/rtl/buffer.sv",
            ],
        }
    ],
}
