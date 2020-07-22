import 'package:flutter/material.dart';
import 'package:promocao/widgets/category_card.dart';

class ListCategoryWidget extends FormField<List> {
  ListCategoryWidget(
      {BuildContext context,
      FormFieldSetter<List> onSaved,
      FormFieldValidator<List> validator,
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
                    return CategoryCard(
                      category: state.value[index],
                      context: context,
                    );
                  });
            });
}
