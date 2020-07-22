import 'package:flutter/material.dart';
import 'package:promocao/widgets/product_card.dart';

class ListProductWidget extends FormField<List>{
  ListProductWidget(
      {BuildContext context,
      FormFieldSetter<List> onSaved,
      FormFieldValidator<List> validator,
      bool isChecked,
      List initialValue,
      bool autoValidate = false})
      : super(
            onSaved: onSaved,
            validator: validator,
            initialValue: initialValue,
            autovalidate: autoValidate,
            builder: (state) {
              return ListView.builder(
                  itemCount: state.value.length,
                  itemBuilder: (context, index) {
                    return ProductCard(
                      product: state.value[index],
                      context: context,
                      isChecked: isChecked,
                    );
                  });
            });

}