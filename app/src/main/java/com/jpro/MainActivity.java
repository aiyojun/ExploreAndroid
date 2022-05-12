package com.jpro;

import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.ListView;
import android.widget.TextView;
import com.jpro.entity.Card;
import com.jpro.tools.OnlyHttp;

import java.util.ArrayList;
import java.util.List;

public class MainActivity extends Activity {

	static class CardAdapter extends ArrayAdapter<Card> {
		public CardAdapter(Context context, int resource,List<Card> objects) {
			super(context, resource, objects);
		}

		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
			Card card = getItem(position);
			View view = LayoutInflater.from(getContext()).inflate(R.layout.card, parent, false);
			TextView textView = view.findViewById(R.id.name);
			textView.setText(card.getName());
			textView = view.findViewById(R.id.no);
			textView.setText(String.valueOf(card.getNo()));
			return view;
		}
	}

	@Override
	protected void onCreate(Bundle bundle) {
		super.onCreate(bundle);
		setContentView(R.layout.activity_controller);
        getActionBar().hide();
		Button httpGet = findViewById(R.id.http_get);
		Log.i(MainActivity.class.getName(), ">> on create");
		httpGet.setOnClickListener(view -> new OnlyHttp()
				.get("http://10.8.7.6:8084")
				.header("Context-Type", "application/json;charset=UTF-8")
				.then(data -> Log.i("MainActivity", data.toString()), err -> Log.e("MainActivity", err.toString()))
				.apply());

		ListView carList = findViewById(R.id.cardList);
		CardAdapter adapter = new CardAdapter(this, R.layout.card, new ArrayList<>()) {{
			add(new Card() {{setNo(1); setName("simon");}});
			add(new Card() {{setNo(2); setName("daisy");}});
		}};
		carList.setAdapter(adapter);
	}

}